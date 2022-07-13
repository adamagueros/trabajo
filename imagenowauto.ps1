$adobe = 'C:\Program Files (x86)\Adobe\Acrobat 10.0\Acrobat\Acrobat.exe'
$printername = 'Payroll Printer'
$drivername = 'ImageNow Printer'
$portname = 'NUL'
$pdf = Get-Childitem "T:\*.pdf"
$arglist = '/S /T "{0}" "{1}" "{2}" {3}' -f $pdf.fullname, $printername, $drivername, $portname
$timepath = '\\nkchapitcdb01\API Timecard Report'
$shortcut = "C:\Users\Public\Desktop\Perceptive Content.lnk"

#Poll for bi-weekly timecard report
Do { start-sleep 7200; $val++ } until (Get-ChildItem "$timepath\*.pdf"); Send-MailMessage -From 'ImageNow Timecards <nkchtcpcntapp01@nkch.org>' -To 'Adams <adam.agueros@nkch.org>' -Subject 'Timecard Import Starting' -body "After $val checks today, the timecard import is starting." -smtpserver 'vscan04.nkch.org' -WarningAction silentlyContinue

#Make sure imagenow is running under current session
Do {
    $processup = Get-Process -name imagenow | ? { $_.SI -eq (Get-Process -PID $PID).SessionId }
    If (!$processup) {
        Start-Process "$shortcut"
        Start-Sleep -seconds 80
    }
} until ($processup)

#Print from 'payroll printer'
Start-Process $adobe -ArgumentList $arglist

#Wait until all payroll printer output files are fully imported and send email to remind me to delete test users docs
do { start-sleep 600 ; "file" } while (Get-ChildItem '\\nkchtcpcntapp01\c$\program files (x86)\imagenow\printer\payroll_printer\output') ; Send-MailMessage -From 'ImageNow Timecards <nkchtcpcntapp01@nkch.org>' -To 'Adams <adam.agueros@nkch.org>' -Subject 'Timecard Import Complete' -body "Imagenow timecare import is complete, remember to delete test users in perceptive documents." -smtpserver 'vscan04.nkch.org' -WarningAction silentlyContinue

#Archive the bi-weekly timecard report
Move-Item -Path "$timepath\*.pdf" -Destination "$timepath\Old Timecards\"
