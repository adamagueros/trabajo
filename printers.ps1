Write-Host "Enter Machine name or partial name" -ForegroundColor green
$name = Read-Host "MACHINE NAME"
Clear-Host
$computer = Get-ADComputer -LDAPFilter "(name=*$name*)"  -properties IPv4Address | Where-Object IPv4Address -ne $null | Select-Object -ExpandProperty name
function network {
    if (!(Test-Connection -ComputerName $entry -BufferSize 16 -Count 1 -ea 0 -quiet -TimeoutSeconds 1)) {
        Write-Host "$entry : Network test failed" -ForegroundColor red
    }
    else {
        Write-Host "$entry : Network test passed" -ForegroundColor green
        $global:final += $entry.Split("")
    }
}

Write-Host ""
Write-Host "#############################################" -ForegroundColor magenta
Write-Host "############# Network Test ##################" -ForegroundColor magenta
Write-Host "#############################################" -ForegroundColor magenta
Write-Host ""

ForEach ($entry in $computer) {
    network
}
Write-Host ""
Write-Host "#############################################" -ForegroundColor magenta
Write-Host "############### Printers ####################" -ForegroundColor magenta
Write-Host "#############################################" -ForegroundColor magenta
Write-Host ""

ForEach ($winner in $final ) {
    $printout = Get-Printer -computername $winner -erroraction SilentlyContinue |  Format-Table -Property Name, DriverName, PortName
    if ($null -ne $printout) {
        Write-Host "$winner Printers:" -foregroundcolor Yellow
        $printout
    }
    else {
        Write-Host "$winner does not have installed printers." -ForegroundColor red
        Write-Host ""
    }
}

Clear-Variable -scope global final
