#This is a 'next step' to the previous minecraft mod script downloader. 
#This script will ask where you would like the mods to be placed in. 
#This script will also request the latest version from modrith.com for fabric

#Function Defs
function Search-Website {
    param(
        [string]$websiteURL,
        [string]$searchWord
    )
    
    #appends the words to create the URL needed for the mod searched for filtered for fabric only
    $searchURL = "$websiteURL/mods?q=$searchWord&g=categories:%27fabric%27"
    Write-Host "`nSearching..."
    $response = Invoke-WebRequest -Uri $searchURL

    # If response is valid
    if ($response.StatusCode -eq 200) {
        $firstResult = $response.Links | Where-Object { $_.InnerText -match $searchWord } | Select-Object -First 1
        if ($firstResult) {
            Write-Host "Search Successful!"
            $searchList = $websiteURL + $firstResult.Href
            #Write-Host "Beginning: $searchList"
            $search = [System.IO.Path]::GetFileNameWithoutExtension($searchList) #Pulls the name of what was searched
            #Write-Host "search var: $search"
            $searchList = $searchList -replace "mod/$search", '' #Replaces first URL to search URL for other mods on the website
            #Write-Host "Before changing: $searchList"
            $searchList = $searchlist + "mods?q=$search"
            #Write-Host "After changing: $searchList"
            $website = (Invoke-WebRequest -Uri $searchList).Links.href #Pulls all Hrefs from search URL
            #Write-Host "Hrefs: $website"
            $modlinks = @() #Creates Array
            #loops over each words pulled from the Href before
            foreach ($line in $website){ 
                if ($line -match "/mod/") { #if the var matchs the keyword '/mod/'
                    $individualMod = $line -split '\s' #stops at white space and stores that string as var
                    
                    foreach ($element in $individualMod){ #loops over the var created before
                        if ($element -match "/mod/" -and $modlinks -notcontains $element) { #makes sure that the string brought in matches '/mod/' and doesn't contain itself (for no double strings of the same char)
                            $modlinks += $element #adds the var into the array
                        }
                    }
                }      
            }
            $searchwebsiteObject = New-Object psobject -Property @{
                searchResult = $searchWord
                listMods = $modlinks
            }
            return $searchwebsiteObject
        }
        else {
            Write-Host "No search results found for '$searchWord' on $websiteURL." # No search found Error
        }
        
    }
}

function list {
    param(
        [string]$keyWord,
        [string]$webURL,
        [array]$modlist
    )

    while ($true) {
        Clear-Host
        Write-Host "
 __   __  _______  ______   ______    ___   __    _  _______  __   __        _______  _______  __   __ 
|  |_|  ||       ||      | |    _ |  |   | |  |  | ||       ||  | |  |      |       ||       ||  |_|  |
|       ||   _   ||  _    ||   | ||  |   | |   |_| ||_     _||  |_|  |      |       ||   _   ||       |
|       ||  | |  || | |   ||   |_||_ |   | |       |  |   |  |       |      |       ||  | |  ||       |
|       ||  |_|  || |_|   ||    __  ||   | |  _    |  |   |  |       | ___  |      _||  |_|  ||       |
| ||_|| ||       ||       ||   |  | ||   | | | |   |  |   |  |   _   ||   | |     |_ |       || ||_|| |
|_|   |_||_______||______| |___|  |_||___| |_|  |__|  |___|  |__| |__||___| |_______||_______||_|   |_|
"
            if ($keyWord -eq '' -and $modlist.length -eq '0') {
                Write-Host "No Mods Found"
            }             
            elseif ($keyWord -eq ''){
                Write-Host "Current Top 10 Mods`n"
            }
            else {        
                $keyWord = $keyWord.Substring(0, 1).ToUpper() + $keyWord.Substring(1)
                Write-Host "Results for `"$keyWord`"`n"
            }

            if ($modlist.length -le '9') {
                for ($i = 0; $i -lt $modlist.length; $i++){
                    if ($i -ge 9)
                    {
                        $Temp = $modlist[$i]
                        $modName = $Temp -replace "/mod/", ""
                        $modName = $modName.Substring(0, 1).ToUpper() + $modName.Substring(1)
                        Write-Host " $($i+1) -  "$modName
                    }
                    else {
                        $Temp = $modlist[$i]
                        $modName = $Temp -replace "/mod/", ""
                        $modName = $modName.Substring(0, 1).ToUpper() + $modName.Substring(1)
                        Write-Host " $($i+1)  -  "$modName
                    }
                }
            }
            else {
                for ($i = 0; $i -le '9'; $i++){
                if ($i -ge 9)
                {
                    $Temp = $modlist[$i]
                    $modName = $Temp -replace "/mod/", ""
                    $modName = $modName.Substring(0, 1).ToUpper() + $modName.Substring(1)
                    Write-Host " $($i+1) -  "$modName
                }
                else {
                    $Temp = $modlist[$i]
                    $modName = $Temp -replace "/mod/", ""
                    $modName = $modName.Substring(0, 1).ToUpper() + $modName.Substring(1)
                    Write-Host " $($i+1)  -  "$modName
                }
            }
            }
            $modSelection = Read-Host "`nEnter 'zzz' to return to search`n`nEnter"

                if ($modSelection -gt 0 -and $modSelection -le '10') {
                    #Write-Host $modlist[$modSelection-1]
                    $temp = $webURL + $modlist[$modSelection-1] + "/versions?l=fabric"
                    #Write-Host $temp
                    $link = Invoke-WebRequest -Uri $temp
                    $download = $link.Links | Where-Object { $_.Href -like "https://cdn.modrinth.com*" }
                    #Write-Host $download
                    #Parse Through versionLink to find latest version of the list.
                    if ($download.Count -gt 0) {
                        $firstLink = $download[$modSelection-1].Href
                        #Write-Host "`n" $firstLink
                        break
                    }
                }
                elseif($modSelection -eq 'zzz') {
                    break
                }
                else {
                    Write-Host ("Failed to find the latest version link")
                    pause
                    Clear-Host
                } 
            }
            $listObject = New-Object psobject -Property @{
                fLink = $firstLink
                selection = $modSelection
            }
            return $listObject
}

Function read-file{
    param (
        [string]$fPath,
        [string]$url,
        [string]$desk
    )
    
    $t = 't'
    while ($t -eq 't'){
        Clear-Host
        Write-Host "
 ______   _______  _______  ___   _  _______  _______  _______ 
|      | |       ||       ||   | | ||       ||       ||       |
|  _    ||    ___||  _____||   |_| ||_     _||   _   ||    _  |
| | |   ||   |___ | |_____ |      _|  |   |  |  | |  ||   |_| |
| |_|   ||    ___||_____  ||     |_   |   |  |  |_|  ||    ___|
|       ||   |___  _____| ||    _  |  |   |  |       ||   |    
|______| |_______||_______||___| |_|  |___|  |_______||___|
"
        Write-Host "Choose mod destination folder below`n`n"
        (Get-ChildItem -Directory -Force -Path $desk)
        $path = Read-Host "`nEnter exact name"
        $folderPath = "$([Environment]::GetFolderPath('Desktop'))\$path"

        #Check if the folder already exists
        if (Test-Path -Path $folderPath) {
            Write-Host "`n'$path' folder selected`n"
            Pause
            Clear-Host
            $t = 'f'
            break
        }
        else {
            Write-Host "Error: Invalid input. Try again..."
            Pause
            Clear-Host
        }
    }
    
    Write-Host "
 _______  __   __  _______  _______  ___   _  ___   __    _  _______                   
|       ||  | |  ||       ||       ||   | | ||   | |  |  | ||       |                  
|       ||  |_|  ||    ___||       ||   |_| ||   | |   |_| ||    ___|                  
|       ||       ||   |___ |       ||      _||   | |       ||   | __                   
|      _||       ||    ___||      _||     |_ |   | |  _    ||   ||  | ___   ___   ___  
|     |_ |   _   ||   |___ |     |_ |    _  ||   | | | |   ||   |_| ||   | |   | |   | 
|_______||__| |__||_______||_______||___| |_||___| |_|  |__||_______||___| |___| |___|
"

    $content = Get-Content -Path $fPath
    $t = @()
    Write-Host "`n"
    Write-Host "
 ______   _______  _     _  __    _  ___      _______  _______  ______   ___   __    _  _______                   
|      | |       || | _ | ||  |  | ||   |    |       ||   _   ||      | |   | |  |  | ||       |                  
|  _    ||   _   || || || ||   |_| ||   |    |   _   ||  |_|  ||  _    ||   | |   |_| ||    ___|                  
| | |   ||  | |  ||       ||       ||   |    |  | |  ||       || | |   ||   | |       ||   | __                   
| |_|   ||  |_|  ||       ||  _    ||   |___ |  |_|  ||       || |_|   ||   | |  _    ||   ||  | ___   ___   ___  
|       ||       ||   _   || | |   ||       ||       ||   _   ||       ||   | | | |   ||   |_| ||   | |   | |   | 
|______| |_______||__| |__||_|  |__||_______||_______||__| |__||______| |___| |_|  |__||_______||___| |___| |___|
"
    foreach ($line in $content) {
        #Write-Host $line

        if($line[0] -match '/' -and $line[1] -match 'm' -and $line[2] -match 'o' -and $line[3] -match 'd' -and $line[4] -match '/') {
            $line = $url + $line + "/versions?l=fabric"
            $link = Invoke-WebRequest -Uri $line
            $download = $link.Links | Where-Object { $_.Href -like "https://cdn.modrinth.com*" }
            #Parse Through versionLink to find latest version of the list.
            if ($download.Count -gt 0) {
                $firstLink = $download[0].Href
                #Write-Host "`n" $firstLink
                $t += $firstLink
            }
        }
        else {
            Write-Host "`nError reading the file. Check if file contents match parameters shown.`n"
            pause
            Clear-Host
        }
    }
            for ($i = 0; $i -lt $t.length; $i++){
                #Write-Host "Array: "$t[$i] "Folder Path: $folderPath"
                $jarName = [System.IO.Path]::GetFileName($t[$i])
                $jName = Join-Path $folderPath -ChildPath $jarName
                try {
                    Invoke-WebRequest -Uri $t[$i] -OutFile $jName
                    Write-Host "`"$jarName`" saved at `"$path`""
                }
                catch {
                    Write-Host "Failed to download the file `"$jarName`"...`n`n"
                }
            }
            Write-Host ""
            Pause
            Clear-Host
}


#Start of Main Script
$main = 't'
while($main -eq 't') {
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
    Write-Host "TIP: Enter 'zzz' to exit"
    Write-Host "`n1 - Folder Selection`n2 - File Upload`n`n"
    $s = Read-Host "Enter"

    if ($s -eq '1') {
        #Selection code
        Clear-Host
        $selection = 't'
        while ($selection -eq 't') {
            $answer = ""
            #Asks the user if they would like to put the mods in a existing directory
            Write-Host "
 _______  _______  ___      _______  _______  _______  ___   _______  __    _ 
|       ||       ||   |    |       ||       ||       ||   | |       ||  |  | |
|  _____||    ___||   |    |    ___||       ||_     _||   | |   _   ||   |_| |
| |_____ |   |___ |   |    |   |___ |       |  |   |  |   | |  | |  ||       |
|_____  ||    ___||   |___ |    ___||      _|  |   |  |   | |  |_|  ||  _    |
 _____| ||   |___ |       ||   |___ |     |_   |   |  |   | |       || | |   |
|_______||_______||_______||_______||_______|  |___|  |___| |_______||_|  |__|
"

            $answer = Read-Host "`nWould you like to put the mods in an existing folder?[Y/n]"

            if ($answer -eq 'y' -or $answer -eq '') {
                
                $desktopPath = "$([Environment]::GetFolderPath('Desktop'))\"
                Clear-Host
                Write-Host "
 ______   _______  _______  ___   _  _______  _______  _______ 
|      | |       ||       ||   | | ||       ||       ||       |
|  _    ||    ___||  _____||   |_| ||_     _||   _   ||    _  |
| | |   ||   |___ | |_____ |      _|  |   |  |  | |  ||   |_| |
| |_|   ||    ___||_____  ||     |_   |   |  |  |_|  ||    ___|
|       ||   |___  _____| ||    _  |  |   |  |       ||   |    
|______| |_______||_______||___| |_|  |___|  |_______||___|
"
                Write-Host "Choose mod folder below"
                (Get-ChildItem -Directory -Force -Path $desktopPath)
                $path = Read-Host "`nEnter exact name"
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
                $selection = 'f'
                break
            }

            elseif ($answer -eq 'n') {
                Clear-Host
                Write-Host "
 _______  ______    _______  _______  _______  ___   __    _  _______                   
|       ||    _ |  |       ||   _   ||       ||   | |  |  | ||       |                  
|       ||   | ||  |    ___||  |_|  ||_     _||   | |   |_| ||    ___|                  
|       ||   |_||_ |   |___ |       |  |   |  |   | |       ||   | __                   
|      _||    __  ||    ___||       |  |   |  |   | |  _    ||   ||  | ___   ___   ___  
|     |_ |   |  | ||   |___ |   _   |  |   |  |   | | | |   ||   |_| ||   | |   | |   | 
|_______||___|  |_||_______||__| |__|  |___|  |___| |_|  |__||_______||___| |___| |___| 
"
                $directory = Read-Host "Creating a new directory on the desktop...`n`nEnter a directory name"
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
                $selection = 'f'
                break
            }
            else {
                Write-Host "`nError: Invalid input...`n"
                Pause
                Clear-Host
            }
        }

        $bool = 't'
        while ($bool -eq 't') {

            Write-Host "
 __   __  _______  ______   ______    ___   __    _  _______  __   __        _______  _______  __   __ 
|  |_|  ||       ||      | |    _ |  |   | |  |  | ||       ||  | |  |      |       ||       ||  |_|  |
|       ||   _   ||  _    ||   | ||  |   | |   |_| ||_     _||  |_|  |      |       ||   _   ||       |
|       ||  | |  || | |   ||   |_||_ |   | |       |  |   |  |       |      |       ||  | |  ||       |
|       ||  |_|  || |_|   ||    __  ||   | |  _    |  |   |  |       | ___  |      _||  |_|  ||       |
| ||_|| ||       ||       ||   |  | ||   | | | |   |  |   |  |   _   ||   | |     |_ |       || ||_|| |
|_|   |_||_______||______| |___|  |_||___| |_|  |__|  |___|  |__| |__||___| |_______||_______||_|   |_|
"
            Write-Host "TIPS:`n`n- Leave blank to show Top 10 Mods.`n- If a mod won't download, try searching for it explicitly and then try again.`n- Enter 'zzz' to exit program."
            $websiteURL = "https://modrinth.com" # Replace this with the URL of the website you want to search
            $searchWord = Read-Host "`nSearch mods"

            if ($searchWord -eq 'zzz') {
                Write-Host "`nGoodBye!`n"
                $bool = 'f'
                $main = 'f'
                break

            }
            else {
                #Calls the website Results function
                $websiteResults = Search-Website -websiteURL $websiteURL -searchWord $searchWord
                while ($true) {
                    #Calls the list function
                    $listResults = list -keyWord $websiteResults.searchResult -webURL $websiteURL -modlist $websiteResults.listMods
                    #Create a filename based on the URL
                    $fileName = [System.IO.Path]::GetFileName($listResults.fLink)
                    
                    if ($listResults.selection -eq 'zzz') {
                        Clear-Host
                        break
                    }
                    else {
                        #Prints to screen the file name and url downloaded from
                        Write-Host "`nDownloading...`n"

                        # Create the file path within the folder
                        $filePath = Join-Path -Path $folderPath -ChildPath $fileName
                        # Download the file
                        try {
                            Invoke-WebRequest -Uri $listResults.fLink -OutFile $filePath
                            $exit = Read-Host "`"$fileName`" saved at `"$folderPath`"`n`nContinue Searching[Y/n]?" 

                            if ($exit -eq 'y') {
                                Clear-Host
                            }
                            elseif ($exit -eq 'n') {
                                Write-Host "`nGoodBye!`n"
                                $bool = 'f'
                                $main = 'f'
                                break
                            }
                            Clear-Host
                        }
                        catch {
                            Write-Host "Failed to download the file...`n`nTIP: Try searching it then downloading!`n"
                            Pause
                            Clear-Host
                        }
                    }
                }  
            }
        }
    }
    elseif ($s -eq '2') {
        
        $fileUpload = 't'
        while ($fileUpload -eq 't'){
            Clear-Host
            Write-Host "
 _______  ___   ___      _______    __   __  _______  ___      _______  _______  ______  
|       ||   | |   |    |       |  |  | |  ||       ||   |    |       ||   _   ||      | 
|    ___||   | |   |    |    ___|  |  | |  ||    _  ||   |    |   _   ||  |_|  ||  _    |
|   |___ |   | |   |    |   |___   |  |_|  ||   |_| ||   |    |  | |  ||       || | |   |
|    ___||   | |   |___ |    ___|  |       ||    ___||   |___ |  |_|  ||       || |_|   |
|   |    |   | |       ||   |___   |       ||   |    |       ||       ||   _   ||       |
|___|    |___| |_______||_______|  |_______||___|    |_______||_______||__| |__||______| 
"
            $dePath = "$([Environment]::GetFolderPath('Desktop'))\" 
            Write-Host "`nPlease choose a file from your desktop you would like to upload`n`nNOTE: the format for the file MUST be:'/mod/<modName>'. Each mod must be seperated by a new line character.`n`nType the name of your file(If your file lacks '.txt' at the end, please append it to see here.)"
            (Get-ChildItem -Force -Path $dePath -Filter "*.txt")
            $uploadName = Read-Host "`nEnter Name"
            $dPath = $dePath + $uploadName
            #Write-Host $depath
            if (Test-Path -Path $dePath) {
                Write-Host "`n'$uploadName' File Selected`n"
                $fileUpload = 'f'
                Pause
                break
                Clear-Host
            }
            else {
                Write-Host "Error: File not found"
                Pause
                Clear-Host
            }
        }
            read-file -fPath $dPath -url $websiteURL -desk $dePath

    }
    elseif ($s -eq 'zzz')
    {
        Write-Host "`nGoodbye!`n"
        $main = 'f'
        break
    }
    else {
        Write-Host "`nError: Invalid Input...`n"
        Pause
        Clear-Host
    }
}

