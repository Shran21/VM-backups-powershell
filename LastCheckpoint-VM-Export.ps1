# Az exportált VM neve
$vmName = "YOUR-VM-NAME"

# A mentések tárolásának mappája
$exportPath = "<--YOUR-PATH-->"

# Az előző mentések számának meghatározása
$keepCount = 2

# Az aktuális dátum lekérdezése és formázása
$currentTime = Get-Date -Format "yyyy-MM-dd"

# A logfájl elérési útvonala
$logFilePath = "<--YOUR-PATH-->"
$logFile = Join-Path -Path $logFilePath -ChildPath "VHDX-export.txt"

# Ha a mentési mappa nem létezik, akkor létrehozzuk azt
 $Timestamp = "$($vmName)_$($currentTime)"
 $exportFolderPath = Join-Path -Path $exportPath -ChildPath $Timestamp

if (!(Test-Path -Path $exportFolderPath -PathType Container)) {
   
    New-Item -ItemType Directory -Path $exportFolderPath | Out-Null
    Write-output "------------------------------------------------------------------------------" >> $logFile
              #Write-Host "Létrehoztuk a mentési mappát: $backupPath $(Get-Date)" 
    Write-output "Létrehoztuk a mentési mappát: $exportFolderPath - időpont: $(Get-Date)" >> $logFile
   
}


# A mentések mappáinak lekérdezése a létrehozás dátuma alapján
$backupFolders = Get-ChildItem -Path $exportPath -Directory | Sort-Object CreationTime -Descending

# Az előző mentések törlése, ha több van, mint amennyit megtartunk
 #(Akár így is meglehetne oldani: Get-ChildItem -Path $exportFolderPath -Directory | Where-Object { $_.Name -match "^$vmName\d{6}$" } | Sort-Object CreationTime -Descending | Select-Object -Skip 2 | Remove-Item -Recurse -Force)
 #(A kommentelt változat nem vizsgálja a mappák darabszámát és nem futtatja egyessével tehát nem mappánként törli azokat hanem azon a kettőn kívül minden mást töröl.)
if ($backupFolders.Count -gt $keepCount) {
    $backupFoldersToDelete = $backupFolders | Select-Object -Skip $keepCount
    foreach ($backupFolder in $backupFoldersToDelete) {
        try {   

            Remove-Item -Path $backupFolder.FullName -Recurse -Force -ErrorAction Stop
            Write-Output "A korábbi szükségtelen $vmName virtuális gép mentése sikeresen törölve: $($backupFolder.FullName)" >> $logFile
        } catch {
            Write-Output "Hiba történt a korábbi szükségtelen $vmName virtuális gép mentés törlése során: $($backupFolder.FullName) - $($_.Exception.Message)" >> $logFile
        }
    }
}

# Lekéri az utoljára létrehozott checkpoint nevét
$checkpointName = Get-VMSnapshot -VMName $vmName | Sort-Object CreationTime -Descending | Select-Object -First 1 | Select-Object -ExpandProperty Name


# A VM exportálás végrehajtása
try {
    Export-VMSnapshot -Name $checkpointName -VMName $vmName -Path  $exportFolderPath -ErrorAction Stop
    Write-Output "A $vmName virtuális gép mentése sikeres megtörtént: $($exportFolderPath)" >> $logFile
} catch {
    Write-Output "Hiba történt a $vmName mentése során: $($_.Exception.Message)" >> $logFile
}
