$adobe = 'C:\Program Files (x86)\Adobe\Acrobat 10.0\Acrobat\Acrobat.exe'
$printername = 'Payroll Printer'
$drivername = 'ImageNow Printer'
$portname = 'NUL'
$pdf = Get-Childitem 'T:\*.pdf'
$arglist = '/S /T "{0}" "{1}" "{2}" {3}' -f $pdf.fullname, $printername, $drivername, $portname
$timepath = '\\nkchapitcdb01\API Timecard Report'
$errorpath = 'C:\Program Files (x86)\ImageNow\printer\payroll_printer\error'
$shortcut = 'C:\Users\Public\Desktop\Perceptive Content.lnk'

#Poll for bi-weekly timecard report
Do { start-sleep 7200; $val++ } until (Get-ChildItem "$timepath\*.pdf"); Send-MailMessage -From 'ImageNow Timecards <nkchtcpcntapp01@nkch.org>' -To 'Adams <adam.agueros@nkch.org>' -Subject 'Timecard Import Starting' -body "After $val checks today, the timecard import is starting." -smtpserver 'vscan04.nkch.org' -WarningAction silentlyContinue

#Make sure imagenow is running under current session
Do {
    $processup = Get-Process -name imagenow | Where-Object { $_.SI -eq (Get-Process -PID $PID).SessionId }
    If (!$processup) {
        Start-Process "$shortcut"
        Start-Sleep -seconds 80
    }
} until ($processup)

#Print from 'payroll printer'
Start-Process $adobe -ArgumentList $arglist

#Wait until all payroll printer output files are fully imported into imagenow
do { start-sleep 300} while (Get-ChildItem '\\nkchtcpcntapp01\c$\program files (x86)\imagenow\printer\payroll_printer\output') ;
#Get error files to list in email
$filelist = get-childitem "$errorpath" | Where-Object { ([datetime]::now.Date -eq $_.lastwritetime.Date) } | Select-Object LastWriteTime, Name;
#Send email with erros and reminder to run "to deletes"
Send-MailMessage -From 'ImageNow Timecards <nkchtcpcntapp01@nkch.org>' -To 'Adams <adam.agueros@nkch.org>' -Subject 'Timecard Import Complete' -body "Imagenow timecard import is complete, remember to delete test users in perceptive documents. Errors:$filelist" -smtpserver 'vscan04.nkch.org' -WarningAction silentlyContinue

#Archive the bi-weekly timecard report
Move-Item -Path "$timepath\*.pdf" -Destination "$timepath\Old Timecards\"
