if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs;
    exit
}

$smiOutput = nvidia-smi --query-compute-apps=pid,name --format=csv
$dgpuProcesses = $smiOutput | ConvertFrom-Csv
echo "Running dGPU processes:"
ForEach ($p in $dgpuProcesses) {
    $p.process_name
}

$confirmation = Read-Host "Kill'em?"
if ($confirmation -eq 'y') {
    ForEach ($p in $dgpuProcesses) {
        kill $p.pid -Force
    }
}
