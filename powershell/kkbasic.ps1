New-Alias -Name grep -Value Select-String
New-Alias -Name crontab -Value Get-ScheduledTask
New-Alias -Name less -Value "out-Host -paging"
New-Alias -Name more -Value "out-Host -paging"
New-Alias -Name l -Value "dir /B"
New-Alias -Name ll -Value "dir /Q /P $*"
New-Alias -Name la -Value "dir /P /A $*"
New-Alias -Name info -Value "help"

# function su {
# Permite escolher várias opcoes
# runas
#     runas /user:CURSO\chitolina /savecred "powershell"

# psssession
#     param($tuser,$tpass,$thost,$tscript)
#     $pass = ConvertTo-SecureString "$tpass" -AsPlainText -Force
#     $cred = New-Object System.Management.Automation.PSCredential($tuser, $pass)
#     Invoke-Command -Computer Curso -ScriptBlock {powershell.exe IEX(New-Object Net.WebClient).DownloadString("http://$thost/$tscript")} -Credential $cred

# psexec
#     .\PsExec64.exe /accepteula -u Curso\chitolina -p password123 cmd
# }

cd C:\Users\Public
echo Write-Host "* Nome de Usuário:"
whoami