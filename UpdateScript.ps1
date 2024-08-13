# Install Windows Updates and patches
function Install-WindowsUpdates {
    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $updateSession.CreateUpdateSearcher()

    $searchResult = $updateSearcher.Search("IsInstalled=0")

    if ($searchResult.Updates.Count -gt 0) {
        $updateInstaller = $updateSession.CreateUpdateInstaller()
        $updateInstaller.Updates = $searchResult.Updates

        Write-Host "Found $($searchResult.Updates.Count) updates to install."

        $installationResult = $updateInstaller.Install()

        if ($installationResult.ResultCode -eq 2) {
            Write-Host "Reboot required to complete installation."
        } elseif ($installationResult.ResultCode -eq 3) {
            Write-Host "Installation completed successfully."
        } else {
            Write-Host "Installation failed with code $($installationResult.ResultCode)."
        }
    } else {
        Write-Host "No updates to install."
    }
}

# Install Windows Updates and patches
Install-WindowsUpdates
