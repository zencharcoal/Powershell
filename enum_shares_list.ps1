param (
    [string]$inputFile,
    [string]$outputFile = "share_permissions.csv"
)

# Function to check share permissions
function Check-SharePermissions {
    param (
        [string]$computerName,
        [ref]$results
    )

    # Get the list of shares on the host
    $shares = Invoke-Command -ComputerName $computerName -ScriptBlock {
        Get-WmiObject -Class Win32_Share
    } -ErrorAction SilentlyContinue

    # Check permissions for each share
    foreach ($share in $shares) {
        $permissions = Invoke-Command -ComputerName $computerName -ScriptBlock {
            param ($shareName)
            $shareSecurity = Get-WmiObject -Class Win32_LogicalShareSecuritySetting -Filter "Name='$shareName'"
            $sd = $shareSecurity.GetSecurityDescriptor().Descriptor
            $dacl = $sd.DACL

            $dacl | ForEach-Object {
                [PSCustomObject]@{
                    ShareName    = $shareName
                    Trustee      = $_.Trustee.Name
                    AccessMask   = $_.AccessMask
                    AceType      = $_.AceType
                }
            }
        } -ArgumentList $share.Name -ErrorAction SilentlyContinue

        # Add the permissions to the results
        $permissions | ForEach-Object {
            if ($_.Trustee -eq $env:USERNAME -or $_.Trustee -eq "Everyone" -or $_.Trustee -eq "Authenticated Users") {
                $results.Value += [PSCustomObject]@{
                    ComputerName = $computerName
                    ShareName    = $share.Name
                    Path         = $share.Path
                    Trustee      = $_.Trustee
                    AccessMask   = $_.AccessMask
                    AceType      = $_.AceType
                }
            }
        }
    }
}

# Validate input parameters
if (-not (Test-Path $inputFile)) {
    Write-Error "Input file does not exist: $inputFile"
    exit 1
}

# Read the list of hostnames from the input file
$computers = Get-Content -Path $inputFile

# Initialize an array to hold the results
$results = @()

# Enumerate shares and check permissions on each host
foreach ($computer in $computers) {
    Write-Output "Checking shares on $computer"
    Check-SharePermissions -computerName $computer -results ([ref]$results)
}

# Output the results to the new file
$results | Export-Csv -Path $outputFile -NoTypeInformation

# Print a message indicating completion
Write-Output "Share permissions have been written to $outputFile."

