Write-Host "Enter Machine name or partial name" -ForegroundColor green
$name = Read-Host "MACHINE NAME"
Clear-Host
$computer = Get-ADComputer -LDAPFilter "(name=*$name*)"  -properties IPv4Address | Where-Object IPv4Address -ne $null | Select-Object -ExpandProperty name
function network {
    if (!(Test-Connection -ComputerName $entry -BufferSize 16 -Count 1 -ea 0 -quiet -TimeoutSeconds 1)) {
        $global:netfail += $entry.Split(" ")
    }
    else {
        Write-Host "$entry" -ForegroundColor green
        $global:final += $entry.Split(" ")
    }
}

Write-Host "#############################################" -ForegroundColor magenta
Write-Host "############# Network Test ##################" -ForegroundColor magenta
Write-Host "#############################################" -ForegroundColor magenta
Write-Host ""
Write-Host "Network test passed:" -ForegroundColor Green
Write-Host ""
ForEach ($entry in $computer) {
    network
}
Write-Host ""
if ($null -ne $netfail) {
    Write-Host "Not on the network:" -ForegroundColor Red
}
Write-Host ""
$netfail -split " "
Write-Host ""
Write-Host "#############################################" -ForegroundColor magenta
Write-Host "############### Printers ####################" -ForegroundColor magenta
Write-Host "#############################################" -ForegroundColor magenta
Write-Host ""

ForEach ($winner in $final ) {
    $printout = Get-Printer -computername $winner -erroraction SilentlyContinue |  
    Format-Table -Property Name, DriverName, PortName
    if ($null -ne $printout) {
        Write-Host "$winner Printers:" -foregroundcolor Yellow
        $printout
    }
    else {
        $global:failed += $winner.Split(" ")
    }
}
if ($null -ne $failed) {
    Write-Host "No Printers installed on:" -ForegroundColor Red
}
Write-Host ""
$failed -split " "
Clear-Variable -name final -scope global
Clear-Variable -name failed -scope global
Clear-Variable -name netfail -scope global
