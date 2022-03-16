function question {
    write-host "SELECT INPUT METHOD" -ForegroundColor cyan
    write-host "A) List" -foregroundcolor yellow
    write-host "B) File" -foregroundcolor yellow
    $answer = read-host "CHOICE"
    Switch ($answer) {
        A { list }
        B { file }
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

question
Invoke-Command -ComputerName $computer {Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\'} | Select-Object PSComputerName, defaultusername , defaultpassword