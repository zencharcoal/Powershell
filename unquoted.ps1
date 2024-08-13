# Function to check for unquoted paths in a given string
function Check-UnquotedPath {
    param (
        [string]$path
    )
    if ($path -match " " -and $path -notmatch '^".*"$') {
        return $true
    }
    return $false
}

# Check all scheduled tasks
$scheduledTasks = Get-ScheduledTask
foreach ($task in $scheduledTasks) {
    $actions = $task.Actions
    foreach ($action in $actions) {
        if ($action.Command) {
            if (Check-UnquotedPath -path $action.Command) {
                Write-Output "Unquoted path found in scheduled task '$($task.TaskName)': $($action.Command)"
            }
        }
    }
}

# Check all services
$services = Get-WmiObject -Class Win32_Service
foreach ($service in $services) {
    $pathName = $service.PathName
    if ($pathName) {
        if (Check-UnquotedPath -path $pathName) {
            Write-Output "Unquoted path found in service '$($service.Name)': $($pathName)"
        }
    }
}

