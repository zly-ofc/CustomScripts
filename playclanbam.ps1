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
        }
        elseif ($Authenticode -eq "NotSigned") {
            $Signature = "Ervenytelen alairas (Nem alairt)"
        }
        elseif ($Authenticode -eq "HashMismatch") {
            $Signature = "Ervenytelen alairas (Hash elteres)"
        }
        elseif ($Authenticode -eq "NotTrusted") {
            $Signature = "Ervenytelen alairas (Nem megbizhato)"
        }
        elseif ($Authenticode -eq "UnknownError") {
            $Signature = "Ervenytelen alairas (Ismeretlen hiba)"
        }
        return $Signature
    } else {
        $Signature = "A fajl nem talalhato"
        return $Signature
    }
}

Clear-Host

Write-Host "";
Write-Host "";
Write-Host -ForegroundColor Red " ______  __       ______   __  __   ______   __       ______   __   __       ______   ______";
Write-Host -ForegroundColor Red "/\  == \/\ \     /\  __ \ /\ \_\ \ /\  ___\ /\ \     /\  __ \ /\  -.\ \     /\  ___\ /\  ___\";
Write-Host -ForegroundColor Red "\ \  _-/\ \ \____\ \  __ \\ \____ \\ \ \____\ \ \____\ \  __ \\ \ \-.  \    \ \___  \\ \___  \";
Write-Host -ForegroundColor Red " \ \_\   \ \_____\\ \_\ \_\\/\_____\\ \_____\\ \_____\\ \_\ \_\\ \_\\"\_\    \/\_____\\/\_____\";
Write-Host -ForegroundColor Red "  \/_/    \/_____/ \/_/\/_/ \/_____/ \/_____/ \/_____/ \/_/\/_/ \/_/ \/_/     \/_____/ \/_____/";

Write-Host -ForegroundColor Blue "				  dc.playclan.hu" -NoNewLine
Write-Host "";

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent());
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator);
}

if (!(Test-Admin)) {
    Write-Warning "Kerlek, futtasd ezt a szkriptet rendszergazdakent."
    Start-Sleep 10
    Exit
}

$sw = [Diagnostics.Stopwatch]::StartNew()

if (!(Get-PSDrive -Name HKLM -PSProvider Registry)){
    Try {
        New-PSDrive -Name HKLM -PSProvider Registry -Root HKEY_LOCAL_MACHINE
    } Catch {
        Write-Warning "Hiba a HKEY_Local_Machine csatlakoztatasakor"
    }
}

$bv = ("bam", "bam\State")
Try {
    $Users = foreach($ii in $bv) {
        Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$($ii)\UserSettings\" | Select-Object -ExpandProperty PSChildName
    }
} Catch {
    Write-Warning "Hiba a BAM kulcs elemzese kor. Valoszinuleg nem tamogatott Windows verzio."
    Exit
}

$rpath = @("HKLM:\SYSTEM\CurrentControlSet\Services\bam\", "HKLM:\SYSTEM\CurrentControlSet\Services\bam\state\")

$UserTime = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation").TimeZoneKeyName
$UserBias = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation").ActiveTimeBias
$UserDay = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation").DaylightBias

$Bam = Foreach ($Sid in $Users) {
    $u++
    foreach($rp in $rpath) {
        $BamItems = Get-Item -Path "$($rp)UserSettings\$Sid" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Property
        Write-Host -ForegroundColor Red "Kivonat keszítese " -NoNewLine
        Write-Host -ForegroundColor Blue "$($rp)UserSettings\$SID"
        $bi = 0 

        Try {
            $objSID = New-Object System.Security.Principal.SecurityIdentifier($Sid)
            $User = $objSID.Translate([System.Security.Principal.NTAccount]) 
            $User = $User.Value
        } Catch {
            $User = ""
        }

        $i = 0
        ForEach ($Item in $BamItems) {
            $i++
            $Key = Get-ItemProperty -Path "$($rp)UserSettings\$Sid" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $Item

            If ($key.length -eq 24) {
                $Hex = [System.BitConverter]::ToString($key[7..0]) -replace "-", ""
                $TimeLocal = Get-Date ([DateTime]::FromFileTime([Convert]::ToInt64($Hex, 16))) -Format "yyyy-MM-dd HH:mm:ss"
                $TimeUTC = Get-Date ([DateTime]::FromFileTimeUtc([Convert]::ToInt64($Hex, 16))) -Format "yyyy-MM-dd HH:mm:ss"
                $Bias = -([convert]::ToInt32([Convert]::ToString($UserBias, 2), 2))
                $Day = -([convert]::ToInt32([Convert]::ToString($UserDay, 2), 2)) 
                $Biasd = $Bias / 60
                $Dayd = $Day / 60
                $TimeUser = (Get-Date ([DateTime]::FromFileTimeUtc([Convert]::ToInt64($Hex, 16))).addminutes($Bias) -Format "yyyy-MM-dd HH:mm:ss") 
                $d = if ((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3) -match '\d{1}') {
                    ((split-path -path $item).Remove(23)).trimstart("\Device\HarddiskVolume")
                } else {
                    $d = ""
                }
                $f = if ((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3) -match '\d{1}') {
                    Split-path -leaf ($item).TrimStart()
                } else {
                    $item
                }	
                $cp = if ((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3) -match '\d{1}') {
                    ($item).Remove(1, 23)
                } else {
                    $cp = ""
                }
                $path = if ((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3) -match '\d{1}') {
                    Join-Path -Path "C:" -ChildPath $cp
                } else {
                    $path = ""
                }			
                $sig = if ((((split-path -path $item) | ConvertFrom-String -Delimiter "\\").P3) -match '\d{1}') {
                    Get-Signature -FilePath $path
                } else {
                    $sig = ""
                }				
                [PSCustomObject]@{
                    'Vizsgalo Idopont' = $TimeLocal
                    'Utolso Futasi Idopont (UTC)' = $TimeUTC
                    'Utolso Futasi Felhasznalo Idopont' = $TimeUser
                    'Alkalmazas' = $f
                    'Utvonal' = $path
                    'Alairas' = $Sig
                    'Felhasznalo' = $User
                    'SID' = $Sid
                    'Regisztracios Utvonal' = $rp
                }
            }
        }
    }
}

$Bam | Out-GridView -PassThru -Title "BAM kulcs bejegyzesek $($Bam.count)  - Felhasznalo Idoszona: ($UserTime) -> AktivBias: ($Bias) - Nyari Idoszama: ($Day)"

$sw.stop()
$t = $sw.Elapsed.TotalMinutes
Write-Host ""
Write-Host "Eltelt Idő $t Perc" -ForegroundColor Yellow
