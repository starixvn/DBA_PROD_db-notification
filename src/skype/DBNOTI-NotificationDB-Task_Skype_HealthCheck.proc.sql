SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE	dbo.Task_Skype_HealthCheck
						@minute			INT			= 5
AS
/*
	Creator:	20200206@Billy
	Task:		Skype Notification - Check Skype notification service status - [Redmine: #128021]
	Database:	DBNOTI.NotificationDB
	
	Revisions:
		- 20170207@Billy:	Initialization - [Redmine: #128021]

	Parameters:
		@minute			: This amount of minutes is the default data getting range. We will check status based on this value.
*/
BEGIN
	SET NOCOUNT ON;
	
	-- Declare variables & temporary schemas --
	DECLARE	@CheckTime		DATETIME
		,	@To				VARCHAR(MAX)
		,	@Subject		NVARCHAR(255)
		,	@Body			NVARCHAR(MAX)
		;

	DECLARE	@FailedMessages AS TABLE (
				NotificationId		INT
					PRIMARY KEY CLUSTERED
			,	ServerName			NVARCHAR(128)
			,	Title				NVARCHAR(128)
			,	SkypeName			NVARCHAR(128)
			);

	-- Get the time of @minute ago --
	SELECT	@CheckTime = DATEADD(MINUTE, -@minute, GETDATE())
		;

	-- Check if any messages reach try count limit --
	UPDATE	sn WITH (ROWLOCK, UPDLOCK)
	SET		TryCount = 100
		,	isNoticed = 3
	OUTPUT	Inserted.NotificationId, Inserted.ServerName, Inserted.Title, sg.SkypeName
	INTO	@FailedMessages (NotificationId, ServerName, Title, SkypeName)
	FROM		dbo.DBA_SkypeNotifications AS sn
	LEFT JOIN	dbo.DBA_SkypeGroup AS sg WITH (NOLOCK)
			ON	sn.SkypeGroupId = sg.SkypeGroupId
	WHERE	sn.TryCount = 5;

	-- Report failed messages via email --
	IF	@@ROWCOUNT > 0
	BEGIN;
		SELECT	@Subject	= N'[DBNOTI] Skype Notification Service Health Check'
			,	@To			= 'pontus@starixsoft.com;'
			;

		SELECT	@Body = (
			SELECT	TOP(1)
					[@style]	= N'width: 100%;'
				,	(	SELECT	[@align]		= N'center'
							,	[node()]		= N'Skype Notification Service Health Check'
						FOR XML PATH ('h1')
						,	TYPE
					)
				,	(	SELECT	[@style]		= N'margin-left:3%'
							,	[node()]		= N'Check time: ' + CONVERT(NVARCHAR, GETDATE(), 120)
						FOR XML PATH ('p')
						,	TYPE
					)
				,	(	SELECT	[@style]		= N'display:table;width:95%;border-spacing:10px;margin:0 auto;'
							,	(	SELECT	[@style]		= N'background-color:red;color:white;text-align:center;display:table-cell;padding:2%;'
										,	[node()]		= N'Failure'
									FOR XML PATH ('h2')
									,	TYPE
								)
						FOR XML PATH ('div')
						,	TYPE
					)
				,	[br]		= ''

				-- Details table --
				,	(	SELECT	[@style]		= N'margin-left:3%'
							,	[node()]		= N'Failed Messages Summary'
						FOR XML PATH ('h2')
						,	TYPE
					)
				,	(	SELECT	[@border]		= 1
							,	[@cellpadding]	= 5
							,	[@width]		= N'95%'
							,	[@style]		= N'margin:0 auto;white-space:nowrap;'
							,	(	SELECT	NULL, [th]		= N'Server'
										,	NULL, [th]		= N'Title'
										,	NULL, [th]		= N'Destination'
										,	NULL, [th]		= N'Count'
									FOR XML PATH ('tr')
									,	TYPE
								)
							,	NULL
							,	(	SELECT	NULL, [td]		= fm.ServerName
										,	NULL, [td]		= fm.Title
										,	NULL, [td]		= fm.SkypeName
										,	NULL, [td]		= COUNT(1)
									FROM	@FailedMessages AS fm
									GROUP BY fm.ServerName, fm.Title, fm.SkypeName
									ORDER BY fm.ServerName, fm.Title, fm.SkypeName
									FOR XML PATH ('tr')
									,	TYPE
								)
						FOR XML PATH ('table')
						,	TYPE
					)

			FOR XML PATH ('body')
			,	ROOT ('html')
		);

		EXECUTE	msdb.dbo.sp_send_dbmail
					@profile_name		= DEFAULT
				,	@recipients			= @To
				,	@subject			= @Subject
				,	@body				= @Body
				,	@body_format		= 'HTML'
				;
	END;

	-- Retry all messages that haven't been acknowledged yet --
	UPDATE	sn WITH (ROWLOCK, UPDLOCK)
	SET		isNoticed = 0
		,	TryCount = sn.TryCount + 1
	FROM	dbo.DBA_SkypeNotifications AS sn
	WHERE	sn.LogDate < @CheckTime								-- Check all message before @CheckTime
		AND	sn.isNoticed <> 1									-- Get only unacknowledged messages
		AND	sn.TryCount < 5
	;

	IF	@@ROWCOUNT <> 0
		RAISERROR('Retrying %d messages.', 0, 0, @@ROWCOUNT) WITH NOWAIT;
END;
GO
/*<info serverAlias="DBNOTI-NotificationDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/