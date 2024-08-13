param (
    [Parameter(Mandatory=$true)]
    [string]$DomainName
)

# Function to get the list of domain controllers
function Get-DomainControllers {
    param (
        [Parameter(Mandatory=$true)]
        [string]$DomainName
    )

    Write-Host "Enumerating domain controllers for domain: $DomainName" -ForegroundColor Cyan

    try {
        $output = nltest /dclist:$DomainName
        $domainControllers = $output | Select-String -Pattern '^\s+(\S+)' | ForEach-Object { $_.Matches[0].Groups[1].Value }
        
        if ($domainControllers) {
            Write-Host "Found domain controllers:" -ForegroundColor Green
            $domainControllers | ForEach-Object { Write-Host $_ }
        } else {
            Write-Host "No domain controllers found." -ForegroundColor Red
        }
    } catch {
        Write-Host ("Failed to enumerate domain controllers: $($_.Exception.Message)") -ForegroundColor Red
    }

    return $domainControllers
}

# Function to query shared folders using LDAP
function Query-SharesLDAP {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Server
    )

    Write-Host "Querying shares on server: $Server using LDAP" -ForegroundColor Cyan

    $shareList = @()

    try {
        $searcher = New-Object DirectoryServices.DirectorySearcher
        $searcher.SearchRoot = "LDAP://$Server"
        $searcher.Filter = "(objectClass=volume)"
        $searcher.PropertiesToLoad.Add("name") | Out-Null
        $searcher.PropertiesToLoad.Add("remotePath") | Out-Null

        $results = $searcher.FindAll()

        foreach ($result in $results) {
            $shareName = $result.Properties["name"]
            $remotePath = $result.Properties["remotePath"]

            if ($shareName -and $remotePath) {
                $shareList += [PSCustomObject]@{
                    ShareName = $shareName
                    Path      = $remotePath
                    Domain    = $Server
                }
            }
        }
    } catch {
        Write-Host ("Failed to query shares on server ${Server} using LDAP: $($_.Exception.Message)") -ForegroundColor Red
    }

    return $shareList
}

# Main script
$domainControllers = Get-DomainControllers -DomainName $DomainName
$allShares = @()

if ($domainControllers) {
    foreach ($dc in $domainControllers) {
        $dcName = $dc.TrimStart('\')
        $allShares += Query-SharesLDAP -Server $dcName
    }

    if ($allShares) {
        Write-Host "Listed shares:" -ForegroundColor Green
        $allShares | Format-Table -AutoSize
    } else {
        Write-Host "No shares found." -ForegroundColor Red
    }
} else {
    Write-Host "No domain controllers to enumerate." -ForegroundColor Red
}
