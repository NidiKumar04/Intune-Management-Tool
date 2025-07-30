# Azure File Downloader Script

A PowerShell script that downloads files from Azure Storage based on date range criteria embedded in the filename.

## File Naming Convention

The script expects files to follow this naming pattern:
```
{StartDate}_{Language}_{EndDate}.{extension}
```

**Example:** `100725_EN_300725.jpg`
- Start Date: `100725` (10th July 2025)
- Language: `EN`
- End Date: `300725` (30th July 2025)
- Extension: `jpg`

## Date Format

All dates should be in `ddMMyy` format:
- `dd` = day (01-31)
- `MM` = month (01-12)
- `yy` = year (00-99, assumes 20xx)

## How It Works

The script downloads files based on this logic:
1. **Date Range Check**: Current date must be between start date and end date (inclusive)
2. **Language Filter**: Matches specified language code
3. **Latest File Selection**: If multiple files match criteria, downloads the one with the latest end date

### Example Scenario

If current date is `150725` (15th July 2025) and you have these files:
- `100725_EN_300725.jpg` ✅ (matches: 10 ≤ 15 ≤ 30)
- `200725_EN_250725.jpg` ❌ (doesn't match: 20 ≤ 15 ≤ 25)
- `050725_EN_200725.jpg` ✅ (matches: 05 ≤ 15 ≤ 20)

The script will download `100725_EN_300725.jpg` because it has the latest end date (30th July).

## Prerequisites

1. **PowerShell 5.1 or later**
2. **Azure PowerShell Module:**
   ```powershell
   Install-Module -Name Az.Storage -Force -AllowClobber
   ```

## Usage

### Basic Usage
```powershell
.\Azure-File-Downloader.ps1 -StorageAccountName "yourstorageaccount" -ContainerName "yourcontainer" -StorageAccountKey "your-storage-key"
```

### Advanced Usage
```powershell
.\Azure-File-Downloader.ps1 `
    -StorageAccountName "yourstorageaccount" `
    -ContainerName "yourcontainer" `
    -StorageAccountKey "your-storage-key" `
    -Language "FR" `
    -CurrentDate "150725" `
    -DownloadPath "C:\Downloads\AzureFiles" `
    -FileExtension "png"
```

## Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `StorageAccountName` | ✅ | - | Azure Storage Account name |
| `ContainerName` | ✅ | - | Container name in the storage account |
| `StorageAccountKey` | ✅ | - | Storage account access key |
| `Language` | ❌ | `"EN"` | Language code to filter files |
| `CurrentDate` | ❌ | Today's date | Current date in ddMMyy format |
| `DownloadPath` | ❌ | `".\Downloads"` | Local download directory |
| `FileExtension` | ❌ | `"jpg"` | File extension to filter |

## Authentication Methods

### Method 1: Storage Account Key (Recommended for automation)
```powershell
.\Azure-File-Downloader.ps1 -StorageAccountName "mystorageaccount" -ContainerName "mycontainer" -StorageAccountKey "abcd1234..."
```

### Method 2: Connection String (Alternative)
You can modify the script to use a connection string instead:
```powershell
# Replace the storage context creation with:
$storageContext = New-AzStorageContext -ConnectionString "DefaultEndpointsProtocol=https;AccountName=..."
```

## Error Handling

The script includes comprehensive error handling for:
- Invalid date formats
- Missing Azure PowerShell modules
- Authentication failures
- Network connectivity issues
- File not found scenarios

## Output

The script provides detailed console output including:
- Files found and filtered
- Date range matching results
- Download progress
- Summary of downloaded file

### Sample Output
```
Azure File Downloader Script Started
Current Date: 150725
Language Filter: EN
File Extension: jpg
Parsed Current Date: 15/07/2025
Connecting to Azure Storage...
Listing files from container: mycontainer
Found 5 files in container
Found matching file: 100725_EN_300725.jpg (Start: 10/07/2025, End: 30/07/2025)
Selected file for download: 100725_EN_300725.jpg
Downloading file to: .\Downloads\100725_EN_300725.jpg
Successfully downloaded: 100725_EN_300725.jpg (245.67 KB)

=== Download Summary ===
File: 100725_EN_300725.jpg
Size: 245.67 KB
Date Range: 10/07/2025 - 30/07/2025
Language: EN
Downloaded to: .\Downloads\100725_EN_300725.jpg
======================

Script completed successfully!
```

## Security Best Practices

1. **Store credentials securely**: Don't hardcode storage keys in scripts
2. **Use Azure Key Vault**: For production environments
3. **Limit permissions**: Use storage accounts with minimal required permissions
4. **Connection strings**: Consider using SAS tokens for time-limited access

## Troubleshooting

### Common Issues

1. **"Az.Storage module not found"**
   ```powershell
   Install-Module -Name Az.Storage -Force -AllowClobber
   ```

2. **"Invalid current date format"**
   - Ensure date is in ddMMyy format (e.g., 150725)

3. **"No files found matching criteria"**
   - Check date ranges in filenames
   - Verify language code matches
   - Confirm file extension filter

4. **Authentication errors**
   - Verify storage account name and key
   - Check container name spelling
   - Ensure container exists and is accessible

## Examples

### Download English files for today's date
```powershell
.\Azure-File-Downloader.ps1 -StorageAccountName "mystorageaccount" -ContainerName "images" -StorageAccountKey "your-key"
```

### Download French files for specific date
```powershell
.\Azure-File-Downloader.ps1 -StorageAccountName "mystorageaccount" -ContainerName "images" -StorageAccountKey "your-key" -Language "FR" -CurrentDate "250725"
```

### Download to custom location with different extension
```powershell
.\Azure-File-Downloader.ps1 -StorageAccountName "mystorageaccount" -ContainerName "documents" -StorageAccountKey "your-key" -DownloadPath "C:\MyFiles" -FileExtension "pdf"
```