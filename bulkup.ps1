function question {
    write-host "SELECT INPUT METHOD" -ForegroundColor cyan
    write-host "A) List" -foregroundcolor yellow
    write-host "B) File" -foregroundcolor yellow
    $answer = read-host "CHOICE"
    Switch ($answer) {
        A {
            clear-host
            list 
            clear-host
        }
        B {
            clear-host
            file 
            clear-host
        }
        default {
            Clear-Host
            question
        }
    }
}

function list {
    Write-host "ENTER MACHINE NAMES:" -ForegroundColor cyan
    $global:computer = @()
    do {
        $myinput = (Read-Host "Machine Name")
        $loopend = (Read-Host "Done? (Y/N)")
        if ($myinput -ne '') { $global:computer += $myinput }
    }
    until ($loopend -eq 'y')
}

function file {
    $correctinput -eq $false
    do {
        clear-host
        Write-Host "ENTER PATH TO SERVER LIST FILE: " -NoNewline -ForegroundColor cyan
        $inputs = Read-Host
        try {
            Get-content $inputs -erroraction stop | out-null
            $correctinput = $true
        }
        catch {
            write-host "Not a file" -ForegroundColor red ; Start-Sleep -s 1 ; Clear-Host
        }
    }
    until ($correctinput -eq $true)
    $global:computer = Get-content $inputs
}

function userent {
    $global:userna = read-host "ENTER NEW USERNAME"
    clear-host
}

function passent {
    $global:pwdnew = read-host "ENTER NEW PASSWORD"
    clear-host
}

function passfun {
    Invoke-Command -ComputerName $computer { Set-Itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\' -Name 'defaultpassword' -value  $using:pwdnew }  
}

function usrfun {
    Invoke-Command -ComputerName $computer { Set-Itemproperty -path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\' -Name 'defaultusername' -value  $using:userna }  
}

function credverify {
    $user = Invoke-Command -ComputerName $server { Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\' }  | Select-Object PSComputerName, defaultusername, defaultpassword
    write-host "$user" -ForegroundColor Green
}

function choices {
    write-host "UPDATE USERNAME OR PASSWORD IN BULK" -ForegroundColor cyan
    write-host "A) Username" -foregroundcolor yellow
    write-host "B) Password" -foregroundcolor yellow
    write-host "C) Both" -foregroundcolor yellow
    $answer = read-host "CHOICES"
    Switch ($answer) {
        A {
            clear-host
            userent
            write-host "The following machines will have their default username updated:"
            $computer 
            ForEach ($server in ($computer)) {
                usrfun
            }   
        }
        B {
            clear-host
            passent
            write-host "The following machines will have their default password updated:" -ForegroundColor Yellow
            $computer
            ForEach ($server in ($computer)) {
                passfun 
            }   
        }
        C {
            clear-host
            userent
            passent
            write-host "The following machines will have their default username AND password updated: "
            $computer
            ForEach ($server in ($computer)) {
                usrfun
                passfun
            }   
        }
        default {
            Clear-Host
            choices
        }
    }
}

$global:displayWidth = 110
$global:displayHeight = 25
write-host ''
write-host '######################################################################################################' -ForegroundColor green
write-host '#      ___           ___                       ___                         ___           ___         #' -ForegroundColor green
write-host '#     /\  \         /\  \       _____         /\  \                       /\__\         /\  \        #' -ForegroundColor green
write-host '#     \:\  \       /::\  \     /::\  \       /::\  \         ___         /:/ _/_       /::\  \       #' -ForegroundColor green
write-host '#      \:\  \     /:/\:\__\   /:/\:\  \     /:/\:\  \       /\__\       /:/ /\__\     /:/\:\__\      #' -ForegroundColor green
write-host '#  ___  \:\  \   /:/ /:/  /  /:/  \:\__\   /:/ /::\  \     /:/  /      /:/ /:/ _/_   /:/ /:/  /      #' -ForegroundColor green
write-host '# /\  \  \:\__\ /:/_/:/  /  /:/__/ \:|__| /:/_/:/\:\__\   /:/__/      /:/_/:/ /\__\ /:/_/:/__/___    #' -ForegroundColor green
write-host '# \:\  \ /:/  / \:\/:/  /   \:\  \ /:/  / \:\/:/  \/__/  /::\  \      \:\/:/ /:/  / \:\/:::::/  /    #' -ForegroundColor green
write-host '#  \:\  /:/  /   \::/__/     \:\  /:/  /   \::/__/      /:/\:\  \      \::/_/:/  /   \::/~~/~~~~     #' -ForegroundColor green
write-host '#   \:\/:/  /     \:\  \      \:\/:/  /     \:\  \      \/__\:\  \      \:\/:/  /     \:\~~\         #' -ForegroundColor green
write-host '#    \::/  /       \:\__\      \::/  /       \:\__\          \:\__\      \::/  /       \:\__\        #' -ForegroundColor green
write-host '#     \/__/         \/__/       \/__/         \/__/           \/__/       \/__/         \/__/        #' -ForegroundColor green
write-host '#                                                                                                    #' -ForegroundColor green
write-host '################################################################## By: Adam Agueros ##################' -ForegroundColor green
question
choices
Write-host "New Settings:" -ForegroundColor Magenta
ForEach ($server in ($computer)) {
    credverify
} 
