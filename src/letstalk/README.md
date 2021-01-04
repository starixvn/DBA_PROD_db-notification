# Letstalk Notification

[![dbms](https://img.shields.io/badge/dbms-SQL_Server-BF0000?style=flat)]()
[![bot](https://img.shields.io/badge/bot-Letstalk-7EBD00?style=flat)](https://www.letstalk.net/)

[![version](https://img.shields.io/badge/version-v2.2.0-0000BF?style=flat)]()

## Infrastructure

### Core system

[![server](https://img.shields.io/badge/server-DBSPARE-BF0000?style=flat-square)]()
[![alias](https://img.shields.io/badge/alias-DBNOTI-00BF00?style=flat-square)]()
[![database](https://img.shields.io/badge/db-NotificationDB-00BFBF?style=flat-square)]()

## Instruction Manual

### Add new notification target

1. Get the ID of Letstalk groups via TW team
1. For each group
    - Insert the metadata into database
    ```tsql
    -- DBNOTI.NotificationDB
    USE NotificationDB;
    INSERT INTO dbo.DBA_LetstalkRooms (RoomId, RoomName, isActive, SendDirectly, Remark, DefaultSubject)
    VALUES  (123456, 'RoomName', 1, 1, NULL, NULL);
    ```
    - Create notification target folder using the [template](src/letstalk/_template-RoomName.RoomId)
    - Make sure the folder name is `${RoomName}.${RoomId}` as inserted metadata in the database.

