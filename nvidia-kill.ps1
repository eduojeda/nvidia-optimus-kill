if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs;
  exit
}

$smiOutput = nvidia-smi --query-compute-apps=pid,name --format=csv
$dgpuProcesses = $smiOutput | ConvertFrom-Csv
echo "Running dGPU processes:`n"
ForEach ($p in $dgpuProcesses) {
  $process = Get-Process -Id $p.pid
  Write-Host $process.ProcessName -NoNewline
  Write-Host " [$($p.pid) - $($p.process_name)]" -ForegroundColor DarkGray
}

Write-Host

$confirmation = Read-Host "Restart processes? [y/n]"
if ($confirmation -eq 'y') {
  Write-Host

  ForEach ($p in $dgpuProcesses) {
    $cmd = (Get-WMIObject Win32_Process -Filter "Handle=$($p.pid)").CommandLine
    $cmd -match '"(?<cmdPath>.+?)"[ ]?(?<cmdArgs>.*)' > $null
    $cmdPath = $Matches.cmdPath
    $cmdArgs = $Matches.cmdArgs
    
    $process = Get-Process -Id $p.pid
    Write-Host "Stopping $($process.ProcessName)..."
    Stop-Process -id $p.pid -Force
    $process.WaitForExit()

    if ($cmdArgs) {
      Write-Host "Starting $($process.ProcessName) as: $cmdPath $cmdArgs"
      Start-Process -FilePath $cmdPath -ArgumentList $cmdArgs
    } else {
      Write-Host "Starting $($process.ProcessName) as: $cmdPath"
      Start-Process -FilePath $cmdPath
    }

    Write-Host
  }
}

Read-Host -Prompt "Press any key to exit"