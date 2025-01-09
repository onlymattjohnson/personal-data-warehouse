# PostgreSQL Backup Script

Automated backup script for PostgreSQL databases running on Windows machines.

## Overview

This script performs automated backups of PostgreSQL databases using PowerShell. It includes:
- Compressed backups in PostgreSQL custom format
- Automatic cleanup of old backups
- Configurable retention period
- Logging of backup operations

## Prerequisites

- PostgreSQL installed on Windows
- PowerShell 5.0 or higher
- Appropriate PostgreSQL user permissions for backup operations

## Setup

1. Clone this repository
```bash
git clone https://github.com/yourusername/postgres-backup-script
```

2. Create your configuration file:
   - Copy `config.template.json` to `config.json`
   - Update the values in `config.json` with your settings

```json
{
    "DB_NAME": "your_database_name",
    "DB_USER": "your_username",
    "BACKUP_DIR": "C:\\PostgreSQL_Backups",
    "PG_DUMP_PATH": "C:\\Program Files\\PostgreSQL\\15\\bin\\pg_dump.exe"
}
```

3. Configure Windows Task Scheduler
   - Open Task Scheduler
   - Create a new task
   - Set trigger (e.g., daily at 3 AM)
   - Action: Start a program
   - Program: `powershell.exe`
   - Arguments: `-ExecutionPolicy Bypass -File "path\to\backup_postgres.ps1"`

## Configuration Options

| Setting | Description | Example |
|---------|-------------|---------|
| DB_NAME | Database name to backup | "mydb" |
| DB_USER | PostgreSQL username | "postgres" |
| BACKUP_DIR | Backup storage location | "C:\\PostgreSQL_Backups" |
| PG_DUMP_PATH | Path to pg_dump executable | "C:\\Program Files\\PostgreSQL\\15\\bin\\pg_dump.exe" |

## Project Structure

```
backup/
├── .gitignore          # Git ignore file
├── config.template.json # Template for configuration
├── backup_postgres.ps1  # Main backup script
└── README.md           # This documentation
```

## Usage

Manual execution:
```powershell
.\backup_postgres.ps1
```

## Backup Files

Backups are stored in the specified backup directory with the naming format:
```
database_name_YYYYMMDD_HHMMSS.backup
```

Each backup file includes:
- Full database schema
- All table data
- Views, functions, and stored procedures
- Users and permissions
- Custom configurations

## Retention Policy

By default, backups older than 30 days are automatically deleted. The retention period can be modified by adjusting the cleanup section in the script:

```powershell
# Delete backups older than X days
Get-ChildItem $BACKUP_DIR -Filter "${DB_NAME}_*.backup" | 
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | 
    Remove-Item
```

## Restore Process

To restore from a backup:

1. Full database restore:
```bash
pg_restore -U your_username -d database_name path/to/backup_file.backup
```

2. Selective restore (specific tables):
```bash
pg_restore -U your_username -d database_name -t table_name path/to/backup_file.backup
```

## Troubleshooting

Common issues and solutions:

1. **Permission Denied**
   - Ensure PostgreSQL user has appropriate permissions
   - Check backup directory permissions
   - Verify Task Scheduler is running with correct credentials

2. **Backup Failed**
   - Confirm PostgreSQL service is running
   - Verify pg_dump path in configuration
   - Check available disk space

3. **Task Scheduler Issues**
   - Ensure PowerShell execution policy is correctly set
   - Verify all paths in configuration are absolute
   - Check Task Scheduler history for error messages

## Security Notes

- Never commit `config.json` to version control
- Ensure backup directory has appropriate access restrictions
- Use a dedicated PostgreSQL user with minimum required permissions
- Regularly audit backup file permissions
- Consider encrypting sensitive backups
