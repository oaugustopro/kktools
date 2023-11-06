# Import-Modules ./kkpeas.ps1
# Import-Modules ./kklib.psm1

function center_print {
    param (
        [string]$Text,
        [string]$PaddingCharacter = '*',
        [ConsoleColor]$ForegroundColor = 'Yellow'
    )
 
    $windowWidth = $host.UI.RawUI.WindowSize.Width
    $textLength = $Text.Length
    $totalPaddingCharacters = $windowWidth - $textLength
    $leftPaddingCharacters = $totalPaddingCharacters / 2
    $rightPaddingCharacters = $totalPaddingCharacters / 2
 
    # If the total padding characters are an odd number, add one more to the right
    if ($totalPaddingCharacters % 2 -ne 0) {
        $rightPaddingCharacters++
    }
 
    $leftPadding = $PaddingCharacter * $leftPaddingCharacters
    $rightPadding = $PaddingCharacter * $rightPaddingCharacters
 
    Write-Host "$leftPadding$Text$rightPadding" -ForegroundColor $ForegroundColor
}

function search_unquoted_path {
    # Busca aplicativos win32 q executam automaticamente, nao estao no windows e nao tem aspas
    gwmi -class Win32_Service -Property Name, DisplayName, PathName, StartMode | Where {$_.StartMode -eq "Auto" -and $_.PathName -notlike "C:\Windows*" -and $_.PathName -notlike '"*'} | select PathName,DisplayName,Name

    # No cmd é assim o comando
    # wmic  service get name,pathname,displayname,startmode | findstr /1 auto | indstr /i /v "C:\Windows\\" | findstr /i /v """

    Write-Host " ?-> Para saber mais da aplicação encontrada, use o comando sc"
    Write-Host "sc.exe qc NomeDoSevico"
    
    Write-Host "?-> Verifique como estão as permissões nos diretórios que estão no caminho do path desejado"
    Write-Host "icacls C:\Program Files\Arquivo.exe"
}

function token_impersonation {
    whoami /priv
    net localgroup Administrator
    echo "* Verifique se está com enable em algum destes privilégios"
    echo "SelmpersonatePrivilege
    # SeAssignPrimaryPrivilege
    # SeTcbPrivilege
    # SeBackupPrivilege
    # SeRestorePrivilege
    # SeCreateTokenPrivilege
    # SeLoadDriverPrivilege
    # SeTakeOwnershipPrivilege
    # SeDebugPrivilege"
}

function check_schedule_tasks {
   # Conseguimos verificar essas Tasks agendadas no sistema através do Powershell e do Cmd. Aqui verificamos as Tasks que nao sao padrao do sistema
    Get-ScheduledTask | where {$_.TaskPath -notlike "\Microsoft*"} | ft TaskName,TaskPath,State

    # Aqui destrinchamos ela ufmpouco mais
    Get-ScheduledTask | where TaskName -EQ 'Update' | Get-ScheduledTaskInfo

    # Verificamos qual o Path que ela chama durante sua execucgao
    $task = Get-ScheduledTask | where TaskName -EQ 'Update'
    $task.Actions

    # No cmd temos um comando similar.
    schtasks  /query /fo LIST /v | findstr /v "\Microsoft"

    # Write-Host "?-> Verifica como estão as permissões nos diretórios que estão no caminho do path desejado"
    # icacls "C:\Program Files"
}

function Show-Menu {
    param (
        [string] $Title = 'My Menu'
    )
    Clear-Host
    center_print  "$Title"
    Write-Host "1: Press '1' to search_unquoted_path."
    Write-Host "2: Press '2' to token_impersonation."
    Write-Host "3: Press '3' to check_schedule_tasks."
    Write-Host "q: Press 'q' to quit."
}

$input = ''
while ($input -ne 'q')
{
     Show-Menu 'Kkpeas'
     $input = Read-Host "Please make a selection"
     switch ($input) {
         '1' {
            search_unquoted_path
         }
         '2' {
            token_impersonation
         }
         '3' {
            check_schedule_tasks
         }
         'q' {
            return
         }
     }
     Read-Host "Press Enter to continue..."
}