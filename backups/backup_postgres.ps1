# Add at start of backup_postgres.ps1
Start-Sleep -Seconds 60  # Wait 1 minute after startup

# Check if PostgreSQL is running
$pgService = Get-Service postgresql*
if ($pgService.Status -ne 'Running') {
    Write-Error "PostgreSQL service is not running"
    exit 1
}

# Load configuration
$config = Get-Content "config.json" | ConvertFrom-Json

# Use config values
$DB_NAME = $config.DB_NAME
$DB_USER = $config.DB_USER
$BACKUP_DIR = $config.BACKUP_DIR
$PG_DUMP = $config.PG_DUMP_PATH
$DATE = Get-Date -Format "yyyyMMdd_HHmmss"
$FILENAME = "${DB_NAME}_${DATE}.backup"

# Ensure backup directory exists
if (!(Test-Path $BACKUP_DIR)) {
    New-Item -ItemType Directory -Path $BACKUP_DIR
}

# Create backup
$env:PGPASSWORD = $config.PGPASSWORD
& $PG_DUMP -U $DB_USER -F c -b -v -f "$BACKUP_DIR\$FILENAME" $DB_NAME
$env:PGPASSWORD = ""

# Delete backups older than 30 days
Get-ChildItem $BACKUP_DIR -Filter "${DB_NAME}_*.backup" | 
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | 
    Remove-Item