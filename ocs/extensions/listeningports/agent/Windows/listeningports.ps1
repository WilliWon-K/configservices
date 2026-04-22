[CmdletBinding()]
Param (
)

###
# Functions
###
function GenerateXML {
    param (
        [Parameter(Mandatory=$True)][string]$port,
        [Parameter(Mandatory=$True)][string]$process
    )

        $port = $($($port.subString(0, [System.Math]::Min(255, $port.Length))))
        $process = $($($process.subString(0, [System.Math]::Min(255, $process.Length))))

        $generateXML += "<LISTENINGPORTS>`n"
        $generateXML += "<PORT>"+ $port +"</PORT>`n"
        $generateXML += "<PROCESS>"+ $process +"</PROCESS>`n"
        $generateXML += "</LISTENINGPORTS>`n"
        return $generateXML
}

###
# Core
###
Try {
    $xml = ''
    write-verbose "[INFO] Gathering listening ports"
    $listening_ports = Get-NetTCPConnection -State Listen | Select-Object -Property LocalPort,@{'Name' = 'ProcessName';'Expression'={(Get-Process -Id $_.OwningProcess).Name}} -Unique | Sort-Object -Property LocalPort
    foreach ($setting in $listening_ports) {
        if ($setting.LocalPort -and $setting.ProcessName) {
            $resultXML += $(GenerateXML $($setting.LocalPort) $($setting.ProcessName))
        }
    } 
    
}
Catch {
    write-verbose $Error[0]
}

write-verbose "[INFO] Sending report..."
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
[Console]::WriteLine($resultXML)
write-verbose "[INFO] Done sending report"
write-verbose "[INFO] Exiting"