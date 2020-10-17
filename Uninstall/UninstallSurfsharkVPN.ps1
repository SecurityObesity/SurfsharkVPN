<#
Copyright © 2020 <dexoidan>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”),
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

This script is developed to uninstall Surfshark VPN that makes it almost completely removed and deleted.
#>

#Requires -RunAsAdministrator

function Test-Administrator  
{  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

function UninstallInRegistry
{
    Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Tracing\Surfshark_RASAPI32" -Recurse -Force
    Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Tracing\Surfshark_RASCHAP" -Recurse -Force
    Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Tracing\Surfshark_RASMANCS" -Recurse -Force
    
    # Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\AppSwitched" -Name "{7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E}\Surfshark\Surfshark.exe" -Force
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\AppSwitched" -Name "${env:USERPROFILE}\AppData\Local\Surfshark\Updates\default\2.6.8.0\1cjhmzij.exe" -Force
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" -Name "Surfshark" -Force
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" -Name "IKEv2-Surfshark Connection" -Force
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Surfshark" -Force
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store" -Name "${env:ProgramFiles(x86)}\Surfshark\Surfshark.exe" -Force
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store" -Name "${env:USERPROFILE}\AppData\Local\Surfshark\Updates\default\2.6.7.0\qcpztt4q.exe" -Force
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store" -Name "${env:USERPROFILE}\AppData\Local\Surfshark\Updates\default\2.6.8.0\1cjhmzij.exe" -Force
    # Remove-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\Network\{4D36E972-E325-11CE-BFC1-08002BE10318}\Descriptions" -Name "TAP-Surfshark Windows Adapter V9" -Force

    <# Possible mismatch #>
    # Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles\{82AFD40A-DDFF-4757-8CF8-9C402C384BEC}" -Recurse -Force
    # Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\Unmanaged\010103000F0000F0000200000F0000F01C6BD5D552BA43F3CDFE661360BA92C95E0F51B1D17E0436537F0395CCC01CBC" -Recurse -Force
}

function DeleteAllFolders
{
    $FolderPaths = @("${env:USERPROFILE}\AppData\Local\Surfshark", "${env:USERPROFILE}\AppData\Roaming\Surfshark", "${env:ProgramFiles(x86)}\Surfshark")
    foreach ($folderName in $FolderPaths)
    {
        Remove-Item -Path $folderName -Recurse -ErrorAction SilentlyContinue -Force
    }
}

function RunUninstall
{
    Write-Host "Surfshark is being terminated..."
    $ServNameArray = @('Surfshark Service')
    foreach ($curElement in $ServNameArray)
    {
        if ((Get-Service -Name $curElement).Status -eq "Running")
        {
            Write-Host "Stopping *$curElement* service..."
            Stop-Service -Name "$curElement" -Force
            Write-Host "*$curElement* is stopped."
        }
        else
        {
            Write-Host "*$curElement* service current state is not running."
        }
    }
    if ((Get-Process -Name "Surfshark" -ErrorAction SilentlyContinue) -eq $null)
    {
        Write-Host "Surfshark process has not been found."
    }
    else
    {
        (Get-Process -Name "Surfshark") | Stop-Process -Force
    }
    Write-Host "Surfshark has been terminated."
    
    <# Uninstall Surfshark Application #>
    $MyApp = Get-WmiObject -Class Win32_Product -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq "Surfshark" }
    $MyApp.Uninstall()

    <# Uninstall Surfshark TAP Driver #>
    $MyApp = Get-WmiObject -Class Win32_Product -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq "Surfshark TAP Driver Windows" }
    $MyApp.Uninstall()

    $tapsurfshark = Get-WindowsDriver -Online -All | Where-Object {$_.CatalogFile -eq "tapsurfshark.cat"} | Select-Object Driver
    & pnputil /delete-driver $tapsurfshark.Driver /force

    UninstallInRegistry
    DeleteAllFolders
    
    Write-Host "Uninstall has been running successfully"
}

if (Test-Administrator)
{
    Write-Host "Are you sure that you want to uninstall Surfshark? (Default is No) (YES/NO) : " -ForegroundColor Yellow -NoNewline; $ReadHost = Read-Host;
    switch($ReadHost)
    {
        YES { RunUninstall }
        NO { Write-Host "You have choose No to continue."; }
        Default { Write-Host "You are required to make your correct response ~ * Case Insensitive *" }
    }
}