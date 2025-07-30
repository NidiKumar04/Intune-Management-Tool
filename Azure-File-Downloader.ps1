# Azure File Downloader Script
# Downloads files from Azure Storage based on date range criteria in filename
# File naming pattern: {StartDate}_{Language}_{EndDate}.{extension}
# Example: 100725_EN_300725.jpg

param(
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountName,
    
    [Parameter(Mandatory=$true)]
    [string]$ContainerName,
    
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountKey,
    
    [Parameter(Mandatory=$false)]
    [string]$Language = "EN",
    
    [Parameter(Mandatory=$false)]
    [string]$CurrentDate = (Get-Date -Format "ddMMyy"),
    
    [Parameter(Mandatory=$false)]
    [string]$DownloadPath = ".\Downloads",
    
    [Parameter(Mandatory=$false)]
    [string]$FileExtension = "jpg"
)

# Import required modules
try {
    Import-Module Az.Storage -ErrorAction Stop
} catch {
    Write-Error "Az.Storage module not found. Please install it using: Install-Module -Name Az.Storage"
    exit 1
}

# Function to parse date from filename format (ddMMyy)
function Parse-DateFromString {
    param([string]$DateString)
    
    try {
        # Parse ddMMyy format
        $day = $DateString.Substring(0, 2)
        $month = $DateString.Substring(2, 2)
        $year = "20" + $DateString.Substring(4, 2)
        
        return [DateTime]::ParseExact("$day/$month/$year", "dd/MM/yyyy", $null)
    } catch {
        Write-Warning "Failed to parse date: $DateString"
        return $null
    }
}

# Function to extract file info from filename
function Get-FileInfo {
    param([string]$FileName)
    
    try {
        # Remove extension
        $nameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($FileName)
        
        # Split by underscore
        $parts = $nameWithoutExt -split '_'
        
        if ($parts.Length -ne 3) {
            return $null
        }
        
        $startDateStr = $parts[0]
        $lang = $parts[1]
        $endDateStr = $parts[2]
        
        $startDate = Parse-DateFromString $startDateStr
        $endDate = Parse-DateFromString $endDateStr
        
        if ($null -eq $startDate -or $null -eq $endDate) {
            return $null
        }
        
        return @{
            FileName = $FileName
            StartDate = $startDate
            EndDate = $endDate
            Language = $lang
            StartDateString = $startDateStr
            EndDateString = $endDateStr
        }
    } catch {
        Write-Warning "Failed to parse filename: $FileName"
        return $null
    }
}

# Function to check if current date falls within file's date range
function Test-DateInRange {
    param(
        [DateTime]$CurrentDate,
        [DateTime]$StartDate,
        [DateTime]$EndDate
    )
    
    return ($CurrentDate -ge $StartDate) -and ($CurrentDate -le $EndDate)
}

# Main script execution
try {
    Write-Host "Azure File Downloader Script Started" -ForegroundColor Green
    Write-Host "Current Date: $CurrentDate" -ForegroundColor Cyan
    Write-Host "Language Filter: $Language" -ForegroundColor Cyan
    Write-Host "File Extension: $FileExtension" -ForegroundColor Cyan
    
    # Parse current date
    $currentDateParsed = Parse-DateFromString $CurrentDate
    if ($null -eq $currentDateParsed) {
        throw "Invalid current date format. Please use ddMMyy format (e.g., 150725)"
    }
    
    Write-Host "Parsed Current Date: $($currentDateParsed.ToString('dd/MM/yyyy'))" -ForegroundColor Cyan
    
    # Create download directory if it doesn't exist
    if (!(Test-Path $DownloadPath)) {
        New-Item -ItemType Directory -Path $DownloadPath -Force | Out-Null
        Write-Host "Created download directory: $DownloadPath" -ForegroundColor Yellow
    }
    
    # Create storage context
    Write-Host "Connecting to Azure Storage..." -ForegroundColor Yellow
    $storageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
    
    # Get all blobs from container
    Write-Host "Listing files from container: $ContainerName" -ForegroundColor Yellow
    $blobs = Get-AzStorageBlob -Container $ContainerName -Context $storageContext
    
    if ($blobs.Count -eq 0) {
        Write-Warning "No files found in container: $ContainerName"
        exit 0
    }
    
    Write-Host "Found $($blobs.Count) files in container" -ForegroundColor Cyan
    
    # Filter files based on extension and parse their info
    $candidateFiles = @()
    
    foreach ($blob in $blobs) {
        $fileName = $blob.Name
        
        # Check file extension
        if (![string]::IsNullOrEmpty($FileExtension) -and !$fileName.EndsWith(".$FileExtension")) {
            continue
        }
        
        # Parse file info
        $fileInfo = Get-FileInfo $fileName
        if ($null -eq $fileInfo) {
            continue
        }
        
        # Check language filter
        if ($fileInfo.Language -ne $Language) {
            Write-Host "Skipping file (language mismatch): $fileName" -ForegroundColor Gray
            continue
        }
        
        # Check if current date falls within the file's date range
        if (Test-DateInRange $currentDateParsed $fileInfo.StartDate $fileInfo.EndDate) {
            Write-Host "Found matching file: $fileName (Start: $($fileInfo.StartDate.ToString('dd/MM/yyyy')), End: $($fileInfo.EndDate.ToString('dd/MM/yyyy')))" -ForegroundColor Green
            
            $fileInfo.Blob = $blob
            $candidateFiles += $fileInfo
        } else {
            Write-Host "Date out of range for file: $fileName" -ForegroundColor Gray
        }
    }
    
    if ($candidateFiles.Count -eq 0) {
        Write-Warning "No files found matching the criteria for date: $CurrentDate and language: $Language"
        exit 0
    }
    
    Write-Host "Found $($candidateFiles.Count) files matching criteria" -ForegroundColor Green
    
    # If multiple files match, select the latest one (by end date, then by start date)
    $selectedFile = $candidateFiles | Sort-Object EndDate, StartDate -Descending | Select-Object -First 1
    
    Write-Host "Selected file for download: $($selectedFile.FileName)" -ForegroundColor Green
    Write-Host "File date range: $($selectedFile.StartDate.ToString('dd/MM/yyyy')) to $($selectedFile.EndDate.ToString('dd/MM/yyyy'))" -ForegroundColor Cyan
    
    # Download the selected file
    $downloadFilePath = Join-Path $DownloadPath $selectedFile.FileName
    
    Write-Host "Downloading file to: $downloadFilePath" -ForegroundColor Yellow
    
    $downloadResult = Get-AzStorageBlobContent -Blob $selectedFile.FileName -Container $ContainerName -Destination $downloadFilePath -Context $storageContext -Force
    
    if (Test-Path $downloadFilePath) {
        $fileSize = (Get-Item $downloadFilePath).Length
        Write-Host "Successfully downloaded: $($selectedFile.FileName) ($([math]::Round($fileSize/1KB, 2)) KB)" -ForegroundColor Green
        
        # Display summary
        Write-Host "`n=== Download Summary ===" -ForegroundColor Magenta
        Write-Host "File: $($selectedFile.FileName)" -ForegroundColor White
        Write-Host "Size: $([math]::Round($fileSize/1KB, 2)) KB" -ForegroundColor White
        Write-Host "Date Range: $($selectedFile.StartDate.ToString('dd/MM/yyyy')) - $($selectedFile.EndDate.ToString('dd/MM/yyyy'))" -ForegroundColor White
        Write-Host "Language: $($selectedFile.Language)" -ForegroundColor White
        Write-Host "Downloaded to: $downloadFilePath" -ForegroundColor White
        Write-Host "======================" -ForegroundColor Magenta
    } else {
        throw "Download failed - file not found at destination"
    }
    
} catch {
    Write-Error "Script execution failed: $($_.Exception.Message)"
    Write-Host "Stack Trace: $($_.ScriptStackTrace)" -ForegroundColor Red
    exit 1
}

Write-Host "`nScript completed successfully!" -ForegroundColor Green