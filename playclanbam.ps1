$ErrorActionPreference = "SilentlyContinue"

function Get-Signature {
    [CmdletBinding()]
    param (
        [string[]]$FilePath
    )

    $Existence = Test-Path -PathType "Leaf" -Path $FilePath
    $Authenticode = (Get-AuthenticodeSignature -FilePath $FilePath -ErrorAction SilentlyContinue).Status
    $Signature = "Ervenytelen alairas (Ismeretlen hiba)"

    if ($Existence) {
        if ($Authenticode -eq "Valid") {
            $Signature = "Ervenyes alairas"
        } elseif ($Authenticode -eq "NotSigned") {
            $Signature = "Ervenytelen alairas (Nem alairt)"
        } elseif ($Authenticode -eq "HashMismatch") {
            $Signature = "Ervenytelen alairas (Hash elteres)"
        } elseif ($Authenticode -eq "NotTrusted") {
            $Signature = "Ervenytelen alairas (Nem megbizhato)"
        } elseif ($Authenticode -eq "UnknownError") {
            $Signature = "Ervenytelen alairas (Ismeretlen hiba)"
        }
        return $Signature
    } else {
        $Signature = "A fajl nem talalhato"
        return $Signature
    }
}

Clear-Host

Write-Host ""
Write-Host ""
Write-Host -ForegroundColor Red " ______  __       ______   __  __   ______   __       ______   __   __       ______   ______"
Write-Host -ForegroundColor Red "/\  == \/\ \     /\  __ \ /\ \_\ \ /\  ___\ /\ \     /\  __ \ /\  -.\ \     /\  ___\ /\  ___\"
Write-Host -ForegroundColor Red "\ \  _-/\ \ \____\ \  __ \\ \____ \\ \ \____\ \ \____\ \  __ \\ \ \-.  \    \ \___  \\ \___  \"
Write-Host -ForegroundColor Red " \ \_\   \ \_____\\ \_\ \_\\/\_____\\ \_____\\ \_____\\ \_\ \_\\ \_\    \/\_____\\/\_____\"
Write-Host -ForegroundColor Red "  \/_/    \/_____/ \/_/\/_/ \/_____/ \/_____/ \/_____/ \/_/\/_/ \/_/ \/_/     \/_____/ \/_____/"

Write-Host -ForegroundColor Blue "				  dc.playclan.hu" -NoNewLine
Write-Host ""

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if (!(Test-Admin)) {
    Write-Warning "Kerlek, futtasd ezt a szkriptet rendszergazdakent."
    Start-Sleep 10
    Exit
}

$sw = [Diagnostics.Stopwatch]::StartNew()

# Szkript további része...

$sw.stop()
$t = $sw.Elapsed.TotalMinutes
Write-Host ""
Write-Host "Eltelt Idő $t Perc" -ForegroundColor Yellow
