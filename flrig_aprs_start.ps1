# PowerShell v2
# Windows PowerShell version of the flrig aprs start script
# Script starts Flrig, waits for Enter key press then proceeds to start JS8Call and JS8Call Utilities
# Once main script starts Flrig rig connection is monitored
# Monitors DBM value via flrig xmlrpc server, if value returned is -128 rig control is lost
# Closes applicatoins
# Waits until RIG_PORT is present (USB port connected / rig has power), restarts applications
# Resumes monitoring DBM value
# Unlike the bash shell version, CTRL C will not close the applications (To do).

$RIG_PORT = "COM4"
$FLRIG_EX = "C:\Program Files (x86)\flrig-2.0.03\flrig.exe"
$FLRIG_IP = "127.0.0.1:12345"
$JS8CALL_EX = "C:\Program Files (x86)\js8call\bin\js8call.exe"
$JS8CALL_U_EX = "./JS8CallUtils_v2.exe"
$DBM_GET_XML = '<?xml version="1.0"?><methodCall><methodName>rig.get_DBM</methodName></methodCall>'
$DBM_DISCONN = '-128'

function Close-Program {
    param (
        [string]$ProcessName
    )

    # Get the process(es) matching the specified process name
    $processes = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue

    if ($processes) {
        # Close each process
        foreach ($process in $processes) {
            $process.CloseMainWindow()
            if (!$process.HasExited) {
                # Wait for up to 10 seconds for the process to close gracefully
                $process.WaitForExit(10000)
                
                if (!$process.HasExited) {
                    # If the process has not exited after waiting, forcefully terminate it
                    $process | Stop-Process -Force
                }
            }
            Write-Host "Closed process $($process.ProcessName) with ID $($process.Id)"
        }
    }
    else {
        Write-Host "No process found with the name $ProcessName"
    }
}


## Start main script ##

$RIG_PORT_TEST = Get-WmiObject Win32_PnPEntity | Where-Object {$_.Name -like "*$RIG_PORT*"}
if (-not $RIG_PORT_TEST) {
    Write-Host "Rig at $RIG_PORT not connected, exiting.."
    return
}
Write-Host "Rig at $RIG_PORT is present."

# Start flrig
Write-Host "Starting Flrig.."
Start-Process -FilePath $FLRIG_EX
Write-Host "Sleep 10"
Start-Sleep -Seconds 10

# Prompt the user to press Enter key
Write-Host " "
Write-Host "When started check JS8Call audio settings / tune"
Write-Host " "
echo "Press Enter key to continue, or Ctrl+C to exit"
$null = Read-Host

# Start JS8Call
Start-Process -FilePath $JS8CALL_EX

# Start JS8CallUtilities_V2
Start-Process -FilePath $JS8CALL_U_EX

## Start Flrig monitor loop ##

while ($true) {
    # Create a new WebClient object
    $webClient = New-Object System.Net.WebClient

    # Set the content type for the POST request
    $webClient.Headers.Add("Content-Type", "application/xml")

    # Make the HTTP POST request and capture the response
    $response = $webClient.UploadString("http://$FLRIG_IP", "POST", $DBM_GET_XML)

    # Extract the value using regex
    $DBM_RESULT = [regex]::Match($response, '<value>(.*?)</value>').Groups[1].Value

    # Print the DBM reading
    Write-Host "DBM reading: $DBM_RESULT"

    # If DBM reading becomes -128, rig control lost
    if ($DBM_RESULT -eq $DBM_DISCONN) {
        Write-Host "Rig control lost, closing applications.."
        # Close applications
        Close-Program -ProcessName "JS8CallUtils_v2"
        Close-Program -ProcessName "js8call"
        Close-Program -ProcessName "js8"
        Close-Program -ProcessName "flrig"
		Start-Sleep 1

        # Wait for rig port to be connected again
        while ($true) {
            $RIG_PORT_TEST = Get-WmiObject Win32_PnPEntity | Where-Object {$_.Name -like "*$RIG_PORT*"}

            if (-not $RIG_PORT_TEST) {
                Write-Host "Rig at $RIG_PORT disconnected, re-check every 5 seconds.."
                Start-Sleep -Seconds 5
            } else {
                Write-Host "Rig at $RIG_PORT connected, start applications.."
                Write-Host "Starting Flrig.."
                Start-Process -FilePath $FLRIG_EX
                Write-Host "Sleep 10"
                Start-Sleep -Seconds 10
                Start-Process -FilePath $JS8CALL_EX
                Start-Process -FilePath $JS8CALL_U_EX
                break
            }
        }
    }

    Start-Sleep -Seconds 1
}
