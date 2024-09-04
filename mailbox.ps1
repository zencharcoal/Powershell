param (
    [Parameter(Mandatory=$true)]
    [string]$EmailAddress
)

# Function to mark all items in a folder and its subfolders as read (Outlook)
function Mark-FolderAsRead {
    param (
        [Parameter(Mandatory=$true)]
        $folder
    )

    Write-Host "Marking all items in folder '$($folder.Name)' and its subfolders as read..."
    $folder.Items | ForEach-Object { $_.UnRead = $false }
    foreach ($subFolder in $folder.Folders) {
        Mark-FolderAsRead -folder $subFolder
    }
    Write-Host "Completed marking folder '$($folder.Name)' as read."
}

# Function to list all folders and subfolders (Outlook)
function List-Folders {
    param (
        [Parameter(Mandatory=$true)]
        $folder,
        [int]$level = 0
    )

    $prefix = " " * ($level * 2)
    Write-Host "$prefix$($folder.Name)"
    foreach ($subFolder in $folder.Folders) {
        List-Folders -folder $subFolder -level ($level + 1)
    }
}

# Function to find a folder by name (case-insensitive, supports partial matches)
function Find-FolderByName {
    param (
        [Parameter(Mandatory=$true)]
        $folder,
        [Parameter(Mandatory=$true)]
        [string]$folderName
    )

    foreach ($subFolder in $folder.Folders) {
        if ($subFolder.Name -like "*$folderName*") {
            return $subFolder
        } else {
            $result = Find-FolderByName -folder $subFolder -folderName $folderName
            if ($result) { return $result }
        }
    }
    return $null
}

# Function to prompt the user for an action
function Prompt-UserAction {
    Write-Host "Please select an action:"
    Write-Host "1. List all folders"
    Write-Host "2. Mark all folders as read"
    Write-Host "3. Mark a specific folder as read"
    Write-Host "4. Create a new folder"
    
    $choice = Read-Host "Enter the number of your choice"
    return $choice
}

# Initialize Outlook application and namespace
$ol = New-Object -ComObject Outlook.Application
$ns = $ol.GetNamespace('mapi')

# Locate the store (mailbox) based on the provided email address
$store = $ns.Stores | Where-Object { $_.DisplayName -eq $EmailAddress }

if ($store -eq $null) {
    Write-Host "Error: Mailbox for '$EmailAddress' not found."
    exit
}

$mb = $store.GetRootFolder()

# Prompt the user for an action
$action = Prompt-UserAction

# Execute the selected action
switch ($action) {
    1 {
        # List all folders
        Write-Host "Listing all folders in mailbox '$EmailAddress'..."
        List-Folders -folder $mb
    }
    2 {
        # Mark all folders as read
        Write-Host "Marking all folders as read in mailbox '$EmailAddress'..."
        Mark-FolderAsRead -folder $mb
    }
    3 {
        # Mark a specific folder as read
        $folderName = Read-Host "Enter the name (or partial name) of the folder to mark as read"
        $folder = Find-FolderByName -folder $mb -folderName $folderName
        if ($folder) {
            Write-Host "Folder found: '$($folder.Name)'"
            Mark-FolderAsRead -folder $folder
        } else {
            Write-Host "Error: Folder '$folderName' not found."
        }
    }
    4 {
        # Create a new folder
        $folderName = Read-Host "Enter the name of the new folder"
        try {
            $newFolder = $mb.Folders.Add($folderName)
            Write-Host "Folder '$folderName' created successfully."
        } catch {
            Write-Host "Error: Failed to create folder '$folderName'."
        }
    }
    default {
        Write-Host "Invalid choice. Exiting."
    }
}

