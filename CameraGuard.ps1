# CameraGuard.ps1

Add-Type @"
using System;
using System.Runtime.InteropServices;

public class LockScreen {
    [DllImport("user32.dll")]
    public static extern bool LockWorkStation();
}
"@

Write-Host "====================================="
Write-Host "          CameraGuard"
Write-Host "====================================="
Write-Host ""
Write-Host "正在监测摄像头设备..."
Write-Host "按 Ctrl+C 可以停止。"
Write-Host ""

$query = @"
SELECT * FROM __InstanceOperationEvent
WITHIN 1
WHERE TargetInstance ISA 'Win32_PnPEntity'
AND (
    TargetInstance.Name LIKE '%Camera%'
    OR TargetInstance.Name LIKE '%摄像头%'
    OR TargetInstance.Name LIKE '%Webcam%'
)
"@

Register-WmiEvent -Query $query -SourceIdentifier "CameraGuard"

try {
    while ($true) {

        $event = Wait-Event -Timeout 1

        if ($null -ne $event) {

            Write-Host ""
            Write-Host "检测到摄像头设备事件！" -ForegroundColor Red
            Write-Host "正在锁定 Windows..."

            [LockScreen]::LockWorkStation()

            Remove-Event -EventIdentifier $event.EventIdentifier -ErrorAction SilentlyContinue
        }

        Start-Sleep -Milliseconds 200
    }
}
finally {
    Unregister-Event -SourceIdentifier "CameraGuard" -ErrorAction SilentlyContinue
}