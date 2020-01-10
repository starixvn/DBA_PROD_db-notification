# Internal Database Notification System

This repo contains source code and documents of the database module of the internal database notification system (aka. DBNOTI).

[![dbms](https://img.shields.io/badge/dbms-SQL_Server-BF0000?style=flat)]()

[![bot](https://img.shields.io/badge/bot-Skype-00AFF0?style=flat)](https://www.skype.com/en/)
[![bot](https://img.shields.io/badge/bot-Letstalk-7EBD00?style=flat)](https://www.letstalk.net/)

[![redmine](https://img.shields.io/badge/redmine-126966-E41321?style=flat)](https://nexdev.net/issues/126966)
[![version](https://img.shields.io/badge/version-v2.2.0-0000BF?style=flat)]()

[![environment](https://img.shields.io/badge/dev-SCHEMA-1E90FF?style=flat)]()
[![environment](https://img.shields.io/badge/test-SCHEMA-4169E1?style=flat)]()
[![environment](https://img.shields.io/badge/sit-SCHEMA-228B22?style=flat)]()
[![environment](https://img.shields.io/badge/prod-FULL-B22222?style=flat)]()
[![environment](https://img.shields.io/badge/dr-FULL-FF8C00?style=flat)]()

## Overview

The DBNOTI system is for Starix DBA to quickly notify related partied about the status of database servers via Skype Bot and Letstalk Notification Center. This system's main purpose is message delivering only. Any further core development must based on this main purpose.

## Infrastructure

### Core system

[![server](https://img.shields.io/badge/server-DBSPARE-BF0000?style=flat-square)]()
[![alias](https://img.shields.io/badge/alias-DBNOTI-00BF00?style=flat-square)]()
[![database](https://img.shields.io/badge/db-NotificationDB-00BFBF?style=flat-square)]()

## Modules

### Letstalk

Please visit [Letstalk directory](src/letstalk) for further information.

### Skype

Please visit [Skype directory](src/skype) for further information.

## Usage

### Registered jobs

### Send notification

To send notification for a registered jobs of current server, execute the following statement:

```sql
EXECUTE	DBNOTI.NotificationDB.dbo.DBA_Letstalk_NewJobMessage (to be updated)
```

### Direct notification

The DBNOTI system also support direct notification (bypass job registration). Please contact Pontus team for further assisstance.

To send direct notification to a Letstalk room, execute the following statement:

```sql
EXECUTE	DBNOTI.NotificationDB.dbo.Letstalk_SendMessage
			@To = 'Letstalk Room TargetName'
		,	@Msg = N'Message content.'
```

To send direct notification to a Skype group, execute the following statement:

```sql
EXECUTE	DBNOTI.NotificationDB.dbo.Skype_SendMessage
			@To = 'Skype Group CodeName'
		,	@Msg = N'Message content.'
```