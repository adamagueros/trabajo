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