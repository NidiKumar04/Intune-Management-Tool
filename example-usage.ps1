# Example Usage Script for Azure File Downloader
# This script demonstrates various ways to use the Azure File Downloader

# =============================================================================
# CONFIGURATION - Update these values with your Azure Storage details
# =============================================================================

$StorageAccountName = "yourstorageaccount"    # Replace with your storage account name
$ContainerName = "yourcontainer"              # Replace with your container name
$StorageAccountKey = "your-storage-key"       # Replace with your storage account key

# =============================================================================
# EXAMPLE 1: Basic usage - Download today's English file
# =============================================================================

Write-Host "=== Example 1: Basic Usage ===" -ForegroundColor Cyan
Write-Host "Downloading today's English file..." -ForegroundColor Yellow

try {
    .\Azure-File-Downloader.ps1 `
        -StorageAccountName $StorageAccountName `
        -ContainerName $ContainerName `
        -StorageAccountKey $StorageAccountKey
} catch {
    Write-Error "Example 1 failed: $($_.Exception.Message)"
}

# =============================================================================
# EXAMPLE 2: Download file for specific date
# =============================================================================

Write-Host "`n=== Example 2: Specific Date ===" -ForegroundColor Cyan
Write-Host "Downloading file for 15th July 2025..." -ForegroundColor Yellow

try {
    .\Azure-File-Downloader.ps1 `
        -StorageAccountName $StorageAccountName `
        -ContainerName $ContainerName `
        -StorageAccountKey $StorageAccountKey `
        -CurrentDate "150725"
} catch {
    Write-Error "Example 2 failed: $($_.Exception.Message)"
}

# =============================================================================
# EXAMPLE 3: Download file for different language
# =============================================================================

Write-Host "`n=== Example 3: Different Language ===" -ForegroundColor Cyan
Write-Host "Downloading French file for today..." -ForegroundColor Yellow

try {
    .\Azure-File-Downloader.ps1 `
        -StorageAccountName $StorageAccountName `
        -ContainerName $ContainerName `
        -StorageAccountKey $StorageAccountKey `
        -Language "FR"
} catch {
    Write-Error "Example 3 failed: $($_.Exception.Message)"
}

# =============================================================================
# EXAMPLE 4: Download to custom location with different file type
# =============================================================================

Write-Host "`n=== Example 4: Custom Location and File Type ===" -ForegroundColor Cyan
Write-Host "Downloading PNG files to custom directory..." -ForegroundColor Yellow

# Create custom download directory
$CustomDownloadPath = "C:\AzureDownloads\Images"
if (!(Test-Path $CustomDownloadPath)) {
    New-Item -ItemType Directory -Path $CustomDownloadPath -Force | Out-Null
    Write-Host "Created directory: $CustomDownloadPath" -ForegroundColor Green
}

try {
    .\Azure-File-Downloader.ps1 `
        -StorageAccountName $StorageAccountName `
        -ContainerName $ContainerName `
        -StorageAccountKey $StorageAccountKey `
        -Language "EN" `
        -DownloadPath $CustomDownloadPath `
        -FileExtension "png"
} catch {
    Write-Error "Example 4 failed: $($_.Exception.Message)"
}

# =============================================================================
# EXAMPLE 5: Batch download for multiple scenarios
# =============================================================================

Write-Host "`n=== Example 5: Batch Download ===" -ForegroundColor Cyan
Write-Host "Downloading files for multiple languages and dates..." -ForegroundColor Yellow

$scenarios = @(
    @{ Language = "EN"; Date = "100725"; Description = "English file for July 10th" },
    @{ Language = "FR"; Date = "150725"; Description = "French file for July 15th" },
    @{ Language = "DE"; Date = "200725"; Description = "German file for July 20th" },
    @{ Language = "ES"; Date = "250725"; Description = "Spanish file for July 25th" }
)

foreach ($scenario in $scenarios) {
    Write-Host "`nDownloading: $($scenario.Description)" -ForegroundColor Yellow
    
    try {
        .\Azure-File-Downloader.ps1 `
            -StorageAccountName $StorageAccountName `
            -ContainerName $ContainerName `
            -StorageAccountKey $StorageAccountKey `
            -Language $scenario.Language `
            -CurrentDate $scenario.Date `
            -DownloadPath ".\Downloads\$($scenario.Language)" `
            -FileExtension "jpg"
    } catch {
        Write-Warning "Failed to download $($scenario.Description): $($_.Exception.Message)"
    }
}

# =============================================================================
# EXAMPLE 6: Error handling demonstration
# =============================================================================

Write-Host "`n=== Example 6: Error Handling Demo ===" -ForegroundColor Cyan
Write-Host "Demonstrating error handling with invalid date..." -ForegroundColor Yellow

try {
    .\Azure-File-Downloader.ps1 `
        -StorageAccountName $StorageAccountName `
        -ContainerName $ContainerName `
        -StorageAccountKey $StorageAccountKey `
        -CurrentDate "999999"  # Invalid date format
} catch {
    Write-Host "Expected error caught: $($_.Exception.Message)" -ForegroundColor Red
}

# =============================================================================
# EXAMPLE 7: Automated daily download (for task scheduler)
# =============================================================================

Write-Host "`n=== Example 7: Automated Daily Download ===" -ForegroundColor Cyan
Write-Host "This example shows how to set up automated daily downloads..." -ForegroundColor Yellow

function Start-DailyDownload {
    param(
        [string]$Language = "EN",
        [string]$LogPath = ".\Logs"
    )
    
    # Create log directory
    if (!(Test-Path $LogPath)) {
        New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
    }
    
    $LogFile = Join-Path $LogPath "daily-download-$(Get-Date -Format 'yyyy-MM-dd').log"
    
    try {
        Write-Host "Starting automated daily download for language: $Language" -ForegroundColor Green
        Start-Transcript -Path $LogFile -Append
        
        .\Azure-File-Downloader.ps1 `
            -StorageAccountName $StorageAccountName `
            -ContainerName $ContainerName `
            -StorageAccountKey $StorageAccountKey `
            -Language $Language `
            -DownloadPath ".\Downloads\Daily"
        
        Write-Host "Daily download completed successfully" -ForegroundColor Green
        
    } catch {
        Write-Error "Daily download failed: $($_.Exception.Message)"
    } finally {
        Stop-Transcript
    }
}

# Run daily download for English files
Start-DailyDownload -Language "EN"

Write-Host "`n=== All Examples Completed ===" -ForegroundColor Green
Write-Host "Check the Downloads folder and subfolders for downloaded files." -ForegroundColor Cyan

# =============================================================================
# TASK SCHEDULER SETUP INSTRUCTIONS
# =============================================================================

Write-Host "`n=== Task Scheduler Setup Instructions ===" -ForegroundColor Magenta
Write-Host @"
To set up automated daily downloads using Windows Task Scheduler:

1. Open Task Scheduler (taskschd.msc)
2. Create Basic Task -> Name it "Azure File Downloader"
3. Set trigger to "Daily" at your preferred time
4. Action: "Start a program"
5. Program: powershell.exe
6. Arguments: -ExecutionPolicy Bypass -File "C:\Path\To\example-usage.ps1"
7. Start in: C:\Path\To\Script\Directory

For PowerShell execution policy issues, run as administrator:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
"@ -ForegroundColor White