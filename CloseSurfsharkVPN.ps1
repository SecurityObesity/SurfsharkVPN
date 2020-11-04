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

This script is developed to all Surfshark VPN users that don't want to have Surfshark running in background, while it's not being used.

Run this script to get rid off Surfshark. Closing down Surfshark is completely safe, it automatically boots up when started.
#>

#Requires -RunAsAdministrator

function Test-Administrator  
{  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

Write-Host "`n"
$text = @"
███████╗██╗   ██╗██████╗ ███████╗███████╗██╗  ██╗ █████╗ ██████╗ ██╗  ██╗    ██╗   ██╗██████╗ ███╗   ██╗
██╔════╝██║   ██║██╔══██╗██╔════╝██╔════╝██║  ██║██╔══██╗██╔══██╗██║ ██╔╝    ██║   ██║██╔══██╗████╗  ██║
███████╗██║   ██║██████╔╝█████╗  ███████╗███████║███████║██████╔╝█████╔╝     ██║   ██║██████╔╝██╔██╗ ██║
╚════██║██║   ██║██╔══██╗██╔══╝  ╚════██║██╔══██║██╔══██║██╔══██╗██╔═██╗     ╚██╗ ██╔╝██╔═══╝ ██║╚██╗██║
███████║╚██████╔╝██║  ██║██║     ███████║██║  ██║██║  ██║██║  ██║██║  ██╗     ╚████╔╝ ██║     ██║ ╚████║
╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═══╝  ╚═╝     ╚═╝  ╚═══╝
"@

$text
Write-Host "`nSurfshark VPN - Secure your digital life`n"

if (Test-Administrator)
{
    Write-Host "Surfshark is being terminated..."
    $ServNameArray = @('Surfshark Service','Surfshark Shadowsocks Service')

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
}

Write-Host
Write-Host "Press any key to continue..."
$null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")