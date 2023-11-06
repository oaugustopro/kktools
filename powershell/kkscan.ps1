function port_scan {
    1..65535 | % {echo ((new-object Net.Sockets.TcpClient).Connect("192.168.2.50",$_)) "Port $_ is open!"} 2>$null
}