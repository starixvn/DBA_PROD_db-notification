SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.Task_DailyDataPurge
AS
/*
	Creator:	20200206@Billy
	Task:		Daily Data Purge - [Redmine: #128038]
	Database:	DBNOTI.NotificationDB

	Revisions:
		- 20200206@Billy:	Initial - [Redmine: #128038]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET NOCOUNT ON;

	-- Variables --
	DECLARE	@PurgeTime	DATETIME
		;

	-- Determine purge time --
	SELECT	@PurgeTime = DATEADD(DAY, -1, CAST(GETDATE() AS DATE))
		;

	-- Purge Letstalk Message --
	WHILE	0 = 0
	BEGIN;
		WITH statuses AS (
			SELECT	TOP(1)
					_letstalk.isNoticed
			FROM	dbo.DBA_LetstalkNotifications AS _letstalk
			ORDER BY _letstalk.isNoticed
			UNION ALL
			SELECT	_letstalk.isNoticed
			FROM	(
				SELECT	__letstalk.isNoticed, [rn] = ROW_NUMBER() OVER(ORDER BY __letstalk.isNoticed ASC)
				FROM		dbo.DBA_LetstalkNotifications AS __letstalk
				INNER JOIN	statuses AS cte
						ON	__letstalk.isNoticed > cte.isNoticed
			) AS _letstalk
			WHERE	_letstalk.rn = 1
		)
		DELETE	TOP(1000) letstalk WITH (ROWLOCK)
		FROM		dbo.DBA_LetstalkNotifications AS letstalk
		INNER JOIN	statuses AS s
				ON	letstalk.isNoticed = s.isNoticed
		WHERE	letstalk.LogDate < @PurgeTime;

		IF	@@ROWCOUNT = 0
			BREAK;
	END;

	-- Purge Skype Message --
	WHILE	0 = 0
	BEGIN;
		WITH statuses AS (
			SELECT	TOP(1)
					_skype.isNoticed
			FROM	dbo.DBA_SkypeNotifications AS _skype
			ORDER BY _skype.isNoticed
			UNION ALL
			SELECT	_skype.isNoticed
			FROM	(
				SELECT	__skype.isNoticed, [rn] = ROW_NUMBER() OVER(ORDER BY __skype.isNoticed ASC)
				FROM		dbo.DBA_SkypeNotifications AS __skype
				INNER JOIN	statuses AS cte
						ON	__skype.isNoticed > cte.isNoticed
			) AS _skype
			WHERE	_skype.rn = 1
		)
		DELETE	TOP(1000) skype WITH (ROWLOCK)
		FROM		dbo.DBA_SkypeNotifications AS skype
		INNER JOIN	statuses AS s
				ON	skype.isNoticed = s.isNoticed
		WHERE	skype.LogDate < @PurgeTime;

		IF	@@ROWCOUNT = 0
			BREAK;
	END;
END;
GO
/*<info serverAlias="DBNOTI-NotificationDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/