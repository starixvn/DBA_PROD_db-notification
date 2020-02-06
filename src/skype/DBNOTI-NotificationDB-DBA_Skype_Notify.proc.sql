SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE	dbo.DBA_Skype_Notify
						@minute			INT			= 5
AS
/*
	Creator:	20180906@Billy
	Task:		Skype Notification - Get messages to notify via Skype - [Redmine: #101021]
	Database:	DBNOTI.NotificationDB
	
	Revisions:
		- 20170207@Billy:	Initialization - [Redmine: #101021]
		- 20190523@Billy:	Move system to DBSPARE - [Redmine: #113125]
		- 20200206@Billy:	Prevent duplicate Skype message - [Redmine: #128021]

	Parameters:
		@minute			: We will get the message from this amount of minutes in the past to the current time
*/
BEGIN
	SET NOCOUNT ON;

	-- Return the result --
	UPDATE	sn WITH (ROWLOCK, UPDLOCK)
	SET		isNoticed = 2
		,	PickupTime = GETDATE()
	OUTPUT	Inserted.NotificationId, Inserted.ServerName, Inserted.Title, Inserted.MsgInfo, Inserted.LogDate, Inserted.SkypeGroupId, Inserted.isSimple
	FROM	dbo.DBA_SkypeNotifications AS sn
	WHERE	sn.LogDate >= DATEADD(MINUTE, -@minute * (sn.TryCount + 1), GETDATE())	-- Get message from @minute ago, including retry
		AND	sn.isNoticed = 0														-- Get only unsent messages
		AND	sn.TryCount < 5															-- Only trying to send 5 times
	;
END;
GO
/*<info serverAlias="DBNOTI-NotificationDB" executers="DBA_Skype" viewers="" isFunction="0" isNested="0"></info>*/