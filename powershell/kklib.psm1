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

function unzip {
    Expand-Archive -Path $Source -DestinationPath $Destination
}

function extract_base64_v1 {
    $Base64String = [System.convert]::ToBase64String((Get-Content -Path 'ARQUIVO A SER ENCODADO' -Encoding Byte))
    $Base64String
    
    [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($EncodedText))
    
}

function extract_base64_v2 {
    Importar o CLM-Base64.ps1
    ConvertTo-Base64 -FilePath .\TopSecret.zip -OutPath .\encoded.txt
}