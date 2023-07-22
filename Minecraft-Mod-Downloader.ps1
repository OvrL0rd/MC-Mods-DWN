# This is a 'next step' to the previous minecraft mod script downloader. 
#This script will ask where you would like the mods to be placed in. 
#This script will also request the latest version from modrith.com for fabric

#Function Defs
function Search-Website {
    param(
        [string]$websiteURL,
        [string]$searchWord
    )

    $searchURL = "$websiteURL/mods?q=$searchWord&g=categories:%27fabric%27"
    Write-Host "`nSearching..."
    $response = Invoke-WebRequest -Uri $searchURL

    if ($response.StatusCode -eq 200) {
        $firstResult = $response.Links | Where-Object { $_.InnerText -match $searchWord } | Select-Object -First 1
        if ($firstResult) {
            Write-Host "Search Successful!"
            $searchList = $websiteURL + $firstResult.Href
            $search = [System.IO.Path]::GetFileNameWithoutExtension($searchList)
            $searchList = $searchList -replace "mod/$search", ''
            $searchList = $searchlist + "mods?q=$search"
            $website = (Invoke-WebRequest -Uri $searchList).Links.href
            $modlinks = @()

            foreach ($line in $website){
                if ($line -match "/mod/") {
                    $individualMod = $line -split '/s'
                
                    foreach ($element in $individualMod){
                        if ($element -match "/mod/" -and $modlinks -notcontains $element) {
                            $modlinks += $element
                        }
                    }
                }      
            } 
        }
    else {
        Write-Host "No search results found for '$searchWord' on $websiteURL."
}
    
}
    else {
        Write-Host "Failed to retrieve search results from $websiteURL. Status code: $($response.StatusCode)"
    }
            Write-Host "`nResults for `"$searchWord`"`n"
            for ($i = 0; $i -le 4; $i++){
                if ($modlinks[$i].length -eq 0){
                    Write-Host " $($i+1)  -   N/A"
                }
                else {
                Write-Host " $($i+1)  -  "$modlinks[$i]
                }
            }
            $modSelection = Read-Host "`nTip: Leave above search bar blank for top 5 downloaded mods`n`nEnter(leave blank and ignore errors to skip)"

            if ($modSelection -eq '1') {
                $temp = $websiteURL + $modlinks[0] + "/versions?l=fabric"
                $link = Invoke-WebRequest -Uri $temp
                $download = $link.Links | Where-Object { $_.Href -like "https://cdn.modrinth.com*" }
                #Parse Through versionLink to find latest version of the list.
                if ($download.Count -gt 0) {
                    $firstLink = $download[0].Href
                    return $firstLink
                }
            }
            elseif ($modSelection -eq '2') {
                $temp = $websiteURL + $modlinks[1] + "/versions?l=fabric"
                $link = Invoke-WebRequest -Uri $temp
                $download = $link.Links | Where-Object { $_.Href -like "https://cdn.modrinth.com*" }
                #Parse Through versionLink to find latest version of the list.
                if ($download.Count -gt 0) {
                    $firstLink = $download[0].Href
                    return $firstLink
                }
            }
            elseif ($modSelection -eq '3') {
                $temp = $websiteURL + $modlinks[2] + "/versions?l=fabric"
                $link = Invoke-WebRequest -Uri $temp
                $download = $link.Links | Where-Object { $_.Href -like "https://cdn.modrinth.com*" }
                #Parse Through versionLink to find latest version of the list.
                if ($download.Count -gt 0) {
                    $firstLink = $download[0].Href
                    return $firstLink
                }
            }
            elseif ($modSelection -eq '4') {
                $temp = $websiteURL + $modlinks[3] + "/versions?l=fabric"
                $link = Invoke-WebRequest -Uri $temp
                $download = $link.Links | Where-Object { $_.Href -like "https://cdn.modrinth.com*" }
                #Parse Through versionLink to find latest version of the list.
                if ($download.Count -gt 0) {
                    $firstLink = $download[0].Href
                    return $firstLink
                }
            }
            elseif ($modSelection -eq '5') {
                $temp = $websiteURL + $modlinks[4] + "/versions?l=fabric"
                $link = Invoke-WebRequest -Uri $temp
                $download = $link.Links | Where-Object { $_.Href -like "https://cdn.modrinth.com*" }
                #Parse Through versionLink to find latest version of the list.
                if ($download.Count -gt 0) {
                    $firstLink = $download[0].Href
                    return $firstLink
                }
            }
            elseif($modSelection -eq '') {
            }
            else {
                Write-Host ("Failed to find the latest version link")
            } 
}


#Start of Main Script

Write-Host "
 __   __  _______      __   __  _______  ______   _______      ______   _     _  __    _ 
|  |_|  ||       |    |  |_|  ||       ||      | |       |    |      | | | _ | ||  |  | |
|       ||       |    |       ||   _   ||  _    ||  _____|    |  _    || || || ||   |_| |
|       ||       |    |       ||  | |  || | |   || |_____     | | |   ||       ||       |
|       ||      _|    |       ||  |_|  || |_|   ||_____  |    | |_|   ||       ||  _    |
| ||_|| ||     |_     | ||_|| ||       ||       | _____| |    |       ||   _   || | |   |
|_|   |_||_______|    |_|   |_||_______||______| |_______|    |______| |__| |__||_|  |__|
"
Write-Host "`nWelcome to MC Mods Downloader!`n"

Pause
Clear-Host

while ($true) {
    $answer = ""
    #Asks the user if they would like to put the mods in a existing directory
    Write-Host "
 __   __  _______      __   __  _______  ______   _______      ______   _     _  __    _ 
|  |_|  ||       |    |  |_|  ||       ||      | |       |    |      | | | _ | ||  |  | |
|       ||       |    |       ||   _   ||  _    ||  _____|    |  _    || || || ||   |_| |
|       ||       |    |       ||  | |  || | |   || |_____     | | |   ||       ||       |
|       ||      _|    |       ||  |_|  || |_|   ||_____  |    | |_|   ||       ||  _    |
| ||_|| ||     |_     | ||_|| ||       ||       | _____| |    |       ||   _   || | |   |
|_|   |_||_______|    |_|   |_||_______||______| |_______|    |______| |__| |__||_|  |__|
"
    
    $answer = Read-Host "`nWould you like to put the mods in an existing folder?[y/n]"

    if ($answer -eq 'y') {
            
        $path = Read-Host "`nWhich folder(desktop only)?"
        $folderPath = "$([Environment]::GetFolderPath('Desktop'))\$path"

        #Check if the folder already exists
        if (Test-Path -Path $folderPath) {
            Write-Host "`n'$path' folder selected`n"
            Pause
            Clear-Host
                
        }
        #Create the folder
        else {
            Write-Host "`nSelected folder not found. Creating folder instead..."
            New-Item -ItemType Directory -Path $folderPath
            Write-Host "`nFolder '$path' created successfully on the desktop.`n"
            Pause
            Clear-Host
        }
        break
    }

    elseif ($answer -eq 'n') {
        # Prompt user to input a directory name where the mods will be stored
        $directory = Read-Host "`nCreating a new directory on the desktop...`n`nEnter a directory name"

        # Generate a folder path
        $folderPath = "$([Environment]::GetFolderPath('Desktop'))\$directory"

        # Check if the folder already exists
        if (Test-Path -Path $folderPath) {
            Write-Host "`nAlready Exsisting Folder: Proceeding with '$directory' folder.`n"
        }
        else {
            # Create the folder
            New-Item -ItemType Directory -Path $folderPath
            Write-Host "Folder '$directory' created successfully on the desktop."
        }
        Pause
        Clear-Host
        break
    }

    else {
        Write-Host "`nError: Invalid input...`n"
        Pause
        Clear-Host
    }
}

while ($true) {


    Write-Host "
 __   __  _______  ______   ______    ___   __    _  _______  __   __        _______  _______  __   __ 
|  |_|  ||       ||      | |    _ |  |   | |  |  | ||       ||  | |  |      |       ||       ||  |_|  |
|       ||   _   ||  _    ||   | ||  |   | |   |_| ||_     _||  |_|  |      |       ||   _   ||       |
|       ||  | |  || | |   ||   |_||_ |   | |       |  |   |  |       |      |       ||  | |  ||       |
|       ||  |_|  || |_|   ||    __  ||   | |  _    |  |   |  |       | ___  |      _||  |_|  ||       |
| ||_|| ||       ||       ||   |  | ||   | | | |   |  |   |  |   _   ||   | |     |_ |       || ||_|| |
|_|   |_||_______||______| |___|  |_||___| |_|  |__|  |___|  |__| |__||___| |_______||_______||_|   |_|
"
    # Main script starts here
    $websiteURL = "https://modrinth.com" # Replace this with the URL of the website you want to search
    $searchWord = Read-Host "`nEnter the mod you would like to download on modrinth"

    $url = Search-Website -websiteURL $websiteURL -searchWord $searchWord

    # Create a filename based on the URL
    $fileName = [System.IO.Path]::GetFileName($url)
        
    #Prints to screen the file name and url downloaded from
    Write-Host "`nDownloading...`n"

    # Create the file path within the folder
    $filePath = Join-Path -Path $folderPath -ChildPath $fileName

    # Download the file
    try {
        Invoke-WebRequest -Uri $url -OutFile $filePath
        $exit = Read-Host "`"$fileName`" saved at `"$folderPath`"`n`nContinue[Y/n]?" 

        if ($exit -eq 'y') {
            Clear-Host
        }
        elseif ($exit -eq 'n') {
            Write-Host "`nGoodBye!`n"
            break
        }
        Clear-Host
    }
    catch {
        Write-Host "Failed to download the file..."
        Write-Host $_.Exception.Message
        Pause
        Clear-Host
    }
}