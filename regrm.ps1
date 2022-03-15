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


function network {
    if (!(Test-Connection -ComputerName $server -BufferSize 16 -Count 1 -ea 0 -quiet)) {
        Write-Host "$server : Network test failed" -ForegroundColor red
    }
    else {
        Write-Host "$server : Network test passed" -ForegroundColor green
    }
}


function remote {
    PsExec \\$server -s winrm.cmd quickconfig -q 2>&1 | Out-Null
    if ($LastExitCode -eq 0) {
        Write-Host "$server : WinRM successfully enabled!" -ForegroundColor green
    }
    else {
        Write-Host "$server : WinRM failed to be enabled" -ForegroundColor red
    }
}


function registry {
    $RemoteRegistry = Get-CimInstance -Class Win32_Service -ComputerName $server -Filter 'Name = "RemoteRegistry"'  2>&1
    if ($RemoteRegistry.State -eq 'Running') {
        Write-Host "$server : Remote Registry is already enabled" -ForegroundColor green
    }
    if ($RemoteRegistry.StartMode -eq 'Disabled') {
        Invoke-command -computername $server { Set-Service -Name RemoteRegistry -StartupType Manual -ErrorAction Stop }
        Write-Host "$server : Remote Registry has been Enabled" -ForegroundColor green
    }
    if ($RemoteRegistry.State -eq 'Stopped') {
        Invoke-command -computername $server { Get-Service -Name RemoteRegistry | Start-Service -ErrorAction Stop }
        Write-Host "$server : Remote Registry has been Started" -ForegroundColor green
    }
    if (!$RemoteRegistry.State) {
        Write-Host "$server : Cannot connect to Registry" -ForegroundColor red
    }
}


question
ForEach ($server in ($computer)) {
    network
    remote
    registry
}



