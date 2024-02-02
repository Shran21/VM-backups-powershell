# Változók inicializálása
$VMName = "YOUR-VM-NAME"  # virtuális gép neve
$checkpointszam = 3  # az utolsó N ellenőrzőpontot megtartjuk
$logFilePath = "C:\VMs\VMcheckpointLog.txt"
$currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
 try {
                
    # Ellenőrzőpont létrehozása
    Checkpoint-VM -VMName $VMName 
    # Csak az utolsó 3 ellenőrzőpont marad meg
    Get-VMSnapshot -VMName $vmName | Sort-Object CreationTime -Descending | Select-Object -Skip 3 | Remove-VMSnapshot -Confirm:$false
    Write-Output "A $vmName virtuális gép ellenőrzőpont létrehozása sikeresen megtörtént. - $currentTime " >> $logFilePath  
           }
 catch {
             
    Write-Output "A $vmName virtuális gép ellenőrzőpont létrehozása közben hiba történt! " >> $logFilePath
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
    Write-Output "Dátum/Idő: $currentTime" >> $logFilePath
      
    }



