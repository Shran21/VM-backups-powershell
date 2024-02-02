# Megadott elérési útvonal, ahol a VHDX és AVHDX fájlok találhatók
$sourcePath = "<--YOUR-PATH-->"

# Megadott elérési útvonal, ahova a VHDX és AVHDX fájlokat menteni kell
$destinationPath = "<--YOUR-PATH-->"

# Megadott mappa elnevezése évszak és hónap szerint
$backupFolderName = "VHDs_" + (Get-Date).ToString("yyyy_MM")

# A VHDX fájl neve kiterjesztés nélkül (a * jelöli az utána következő részt)
$prefix = "YOURVM-NAME*"


# Teljes elérési útvonal a mentési mappához
$backupPath = Join-Path -Path $destinationPath -ChildPath $backupFolderName

# A logolás kezdése
$logFilePath = Join-Path -Path $backupPath -ChildPath "VHDX-Backuplog.txt"

# Ha a mentési mappa nem létezik, akkor létrehozzuk azt
if (!(Test-Path -Path $backupPath -PathType Container)) {
    New-Item -ItemType Directory -Path $backupPath
              #Write-Host "Létrehoztuk a mentési mappát: $backupPath $(Get-Date)" 
    Write-output "Létrehoztuk a mentési mappát: $backupPath $(Get-Date)" >> $logFilePath
    Write-output "------------------------------------------------------------------------------" >> $logFilePath
}


# A mentés megkezdésének logolása
Write-output "Mentés elkezdve:" $(Get-Date)  >> $logFilePath


# Elindítjuk a mentést
$vhdxFiles = Get-ChildItem -Path $sourcePath -Filter $prefix | Sort-Object LastWriteTime 
$backupCount = 0
foreach ($vhdx in $vhdxFiles) {
   # $avhdx = $vhdx.FullName + ".avhdx"
    $backupVHDX = Join-Path -Path $backupPath -ChildPath $vhdx.Name
            # Write-Host "Másoljuk a fájlt: $($vhdx.Name) -> $($backupVHDX)" | Out-File -FilePath $logFilePath -Append
     Write-output "Másoljuk a fájlt: $($vhdx.Name) -> $($backupVHDX)" >> $logFilePath
    #$backupAVHDX = Join-Path -Path $backupPath -ChildPath $vhdx.Name
  
    if ((Test-Path -Path $backupVHDX)) {
                    #Write-Host "$vhdx már létezik a mentési mappában." | Out-File -FilePath $logFilePath -Append
        Write-output "$vhdx már létezik a mentési mappában." >> $logFilePath
    }
   else {
        Copy-Item -Path $vhdx.FullName -Destination $backupVHDX
        $backupCount++
        #Write-Host "$($vhdx.Name) másolása sikeres." | Out-File -FilePath $logFilePath -Append
        Write-output "$($vhdx.Name) másolása sikeres." >> $logFilePath


     }  
}

$mergedvhdxFiles = Get-ChildItem -Path $backupPath -Filter $prefix | Sort-Object LastWriteTime -Descending
foreach ($mergedvhdxs in $mergedvhdxFiles) {

    $mergedBackupVHDX = Join-Path -Path $backupPath -ChildPath $mergedvhdxs.Name

 # VHDX és AVHDX fájlok egyesítése
        #$mergedAVHDX = Join-Path -Path $backupPath -ChildPath $vhdx.Name #Ha nem működne a $backupVHDX-el megfelelően
        $mergedVHDXfile = Get-ChildItem -Path $backupPath -Filter *.vhdx
        $mergedVHDX = Join-Path -Path $backupPath -ChildPath $mergedVHDXfile
           if ( $mergedBackupVHDX -ne $mergedVHDX) {

            $parentFilePath = (Get-VHD -Path $mergedBackupVHDX).ParentPath # A backupVHDX változóban lekérdezett avhdx vagy vhdx fájl szülő merevlemezést kérdezzük le és adjuk át a parentFilePath változónak
            $parentFileName =  $backupPath + "\" + (Split-Path $parentFilePath -Leaf)

                        # Write-Host "Egyesítjük a fájlt: $($backupVHDX) -> $($mergedVHDX)"
             Write-output  "Megkezdjük a fájl egyesítését: $($mergedBackupVHDX) -> $($parentFileName)" >> $logFilePath
            # Merge-VHD -Path $backupVHDX -DestinationPath $mergedVHDX -Force 
              try {
                
                 Merge-VHD -Path $mergedBackupVHDX -DestinationPath $parentFileName -Force -ErrorAction Stop
                 Write-output "$mergedBackupVHDX egyesítve a $parentFileName fájlba."  >> $logFilePath
                }
              catch {
               $errorMessage = $_.Exception.Message
               $errorStackTrace = $_.Exception.StackTrace
               $errorType = $_.Exception.GetType().FullName
               $innerException = $_.Exception.InnerException
               $errorAction = $ErrorAction
               $errorVariable = $ErrorVariable

            
               Write-Output "Hiba üzenet: $errorMessage" >> $logFilePath
               Write-Output "Stacktrace: $errorStackTrace" >> $logFilePath
               Write-Output "Hiba típusa: $errorType" >> $logFilePath
               Write-Output "Belső hiba: $innerException" >> $logFilePath
               Write-Output "ErrorAction értéke: $errorAction" >> $logFilePath
               Write-Output "ErrorVariable értéke: $errorVariable" >> $logFilePath
               $currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
               Write-Output "Dátum/Idő: $currentTime" >> $logFilePath
           
                }

            }
          
 }

 
# Logoljuk a darabszámot
       #Write-Host "Mentett fájlok darabszáma: $backupCount" | Out-File $logFilePath -Append
Write-output  "Mentett fájlok darabszáma: $backupCount" >> $logFilePath
Write-output "Mentés befejezve:" $(Get-Date)  >> $logFilePath
Write-output "------------------------------------------------------------------------------" >> $logFilePath