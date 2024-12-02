<#
Descripcion: 
    Script dedicado netamente para el funcionamiento de Salesforce.
    Inicia con la lectura del archivo ArchivosCambiados.txt. El contenido del archivo debe tener almenos una l;inea con la siguiente estructura:
      D dataPack/OrchestrationDependencyDefinition/Archivo1
      M dataPack/OrchestrationDependencyDefinition/Archivo2
      A dataPack/OrchestrationDependencyDefinition/Archivo3
    Cada linea del archivo se compone de 2 grupos:
    - Inicia con alguna de las siguientes letras [D,M,A], donde D=Delete; A=Add y M=Modified
    - Ruta completa del archivo impactado 
Copia desde una ruta origen (X) hacia una ruta destino (Y) el congunto de archivos que se encuentran indicados dentro del archivo
ArchivosCambiados.txt
Parametros:
@sourcePath = ruta origen
@targetPath = ruta destino
#>

<# Funcion que recorre linea a linea el contenido que se encuentra dentro del parametro $linesFile
   Cada line puede representra una ruta de directorio o un archivo. 
   @param $linesFile Contenido de las diferencias que se encuentran dentro de ArchivosCambiados.txt
   @param $originPath ruta origen
   @param $targetPath ruta destino
#>
#$linesFile = Get-Content -Path "manifest/package/destructiveChangesPost.xml"

$newFolderName = "NuevoDirectorio"
New-Item -ItemType Directory -Path $newFolderName

$differenceFilePath = Join-Path -Path $newFolderName -ChildPath "DiferenciasArchivosCambiados.xml"
git diff --name-status HEAD~1> $differenceFilePath
$gitDiffOutput = Get-Content -Path $differenceFilePath
Write-Host "Diferencias en el espacio de trabajo actual:" -ForegroundColor Yellow
Write-Output $gitDiffOutput

#$linesFile = Get-Content -Path "./ArchivosCambiados/DiferenciasArchivosCambiados.xml"
$linesFile = = Get-Content -Path $env:DIFF_FILE_PATH
function FilterAndCopyFiles (){
    param (
        $linesFile, 
        [string]$originPath, 
        [string]$targetPath
    )
    Write-Host '******** Funcion FilterAndCopyFiles ***********'
    $filesCount = @{ result = 0 }
    $finalSourcePath = ''
    $finalTargetPath = ''
    $path_datapack = @()
<# Iterando cada linea del ArchivosCambiados.txt #>
    foreach($line in $linesFile){
        #Se filtra solo los archivos impactados que se encuentren dentro de dataPack o force-app.        
        #Write-Host "Line: $line" -ForegroundColor Blue
        if($line -match '[D,M,A,R]\d{0,4}\tdataPack\/.*$' -or $line -match '[D,M,A,R]\d{0,4}\tforce-app\/.*$'){
            if($line -match '[R]\d{0,4}\tdataPack\/.*$' -or $line -match '[R]\d{0,4}\tforce-app\/.*$'){
                #Write-Host "Linea renombre de archivo: $line" -ForegroundColor DarkRed
                $line_split = $line.split("`t")
                $status_line = $line_split[0]
                $path_file = $line_split[2]
            }else{
                $line_split = $line.split("`t")
                $status_line = $line_split[0]
                $path_file = $line_split[1]
            }            
            $finalSourcePath = $originPath + $path_file
            $finalTargetPath = $targetPath + $path_file
            #Write-Host "path_file: $path_file" -ForegroundColor Green
            # Validando si el archivo modificado se encuentra dentro de directorio 'dataPack'
            if($path_file -match 'dataPack\/[^\/]+\/[^\/]+\/'){
                Write-Host "`tEn dataPack:" -ForegroundColor Yellow
                # Extrae la ruta del componente
                $componentFolder = $path_file -replace '^(dataPack\/[^\/]+\/[^\/]+)\/.*$', '$1'
                #Write-Host "`tcomponentFolder: $componentFolder"
                $componentPath = $originPath + $componentFolder
                #Write-Host "componentPath: $componentPath"
                $destinationComponentPath = $targetPath + $componentFolder
                $destinationComponentPath = Split-Path $destinationComponentPath -Parent
                #Write-Host "`tdestinationComponentPath: $destinationComponentPath"
                # Copia toda la carpeta del componente
                if(-not ($path_datapack.Contains($componentFolder)) -and (Test-Path -Path $componentPath)){
                    if(-not (Test-Path -Path $destinationComponentPath)){
                        New-Item -ItemType Directory -Force -Path $destinationComponentPath
                    }
                    Copy-Item -Path $componentPath -Destination $destinationComponentPath -Recurse -Force
                    $path_datapack += $componentFolder
                    Write-Host "Copiada ruta: $componentFolder"
                    $filesCount.result++                
                }
            }elseif ($path_file -match 'force-app\/[^\/]+\/[^\/]+\/classes+\/' -or $path_file -match 'force-app\/[^\/]+\/[^\/]+\/triggers+\/'){
                # Extrae la ruta del componente
                if($status_line -ne "D"){
                    $componentFolder = $path_file -replace '^(force-app\/[^\/]+\/[^\/]+\/classes\/)(.*$)', '$1'
                    $fileName = $path_file -replace '^(force-app\/[^\/]+\/[^\/]+\/classes\/)(.*$)', '$2'
                    $fileName = $fileName.split(".")[0]
                    Write-Host "`tforce-app (classes - triggers)" -ForegroundColor Yellow
                    $componentPath = $originPath + $componentFolder + $fileName + ".*"
                    $destinationComponentPath = $targetPath + $componentFolder
                    if(-not (Test-Path -Path $destinationComponentPath)){
                        New-Item -ItemType Directory -Force -Path $destinationComponentPath
                    }
                    Copy-Item -Path $componentPath -Destination $destinationComponentPath -Recurse
                    $filesCount.result++
                }
            }elseif ($path_file -match 'force-app\/[^\/]+\/[^\/]+\/lwc+\/'){
                Write-Host "`tforce-app (lwc)" -ForegroundColor Yellow
                $componentFolder = $path_file -replace '^(force-app\/+.*\/)(.*$)', '$1'
                $componentPath = $originPath + $componentFolder
                Write-Host "componentPath: $componentPath"
                $destinationComponentPath = $targetPath + $componentFolder
                $destinationComponentPath = Split-Path $destinationComponentPath -Parent
                if(-not ($path_datapack.Contains($componentFolder)) -and (Test-Path -Path $componentPath)){
                    if(-not (Test-Path -Path $destinationComponentPath)){
                        New-Item -ItemType Directory -Force -Path $destinationComponentPath
                    }
                    Copy-Item -Path $componentPath -Destination $destinationComponentPath -Recurse -Force
                    $path_datapack += $componentFolder
                    Write-Host "Copiada ruta: $componentFolder"
                    $filesCount.result++                
                }
            }else{                
                if($status_line -ne "D"){
                    $componentFolder = $path_file -replace '^(force-app\/.*\/{1,6})(.*$)', '$1'
                    $destinationComponentPath = $targetPath + $componentFolder
                    $componentPath = $originPath + $path_file
                    Write-Host "`t En force-app" -ForegroundColor Yellow
                    #Write-Host "componentPath: $componentPath"
                    #Write-Host "destinationComponentPath: $destinationComponentPath"
                    if(-not (Test-Path -Path $destinationComponentPath)){
                        New-Item -ItemType Directory -Force -Path $destinationComponentPath
                    }
                    Copy-Item -Path $componentPath -Destination $destinationComponentPath -Recurse
                    $filesCount.result++
                }
            }
        }
    }
    return $filesCount
}
function PrintModifiedFiles (){
    param (
        $contentFile
    )
    Write-Host "ARCHIVOS MODIFICADOS:"
    foreach($line in $contentFile){
        Write-Host "`t---$($line)"
    }
    Write-Host "`r`n"
}
<# *** Data para escenario local  *** 
$sourcePath = 'D:/REPOSITORIOS_ADS/SalesForce_Insp/'
$targetPath = 'D:/REPOSITORIOS_ADS/SalesForce_Insp/'
<# ********************** #>
$folderName = 'Archivos_Modificados/'
$targetPath = $sourcePath+$folderName
Write-Host 'Directorio raiz origen: '  $sourcePath
Write-Host 'Directorio raiz destino: ' + $targetPath
#Se elimina el conjunto de archivos /direcorio en la ruta destino 
if(Test-Path -Path $targetPath){
    Get-ChildItem -Path $targetPath -Recurse| Foreach-object {Remove-item -Recurse -path $_.FullName }
}else{
    New-Item -ItemType Directory -Force -Path $targetPath
}
$sourcePathChangedFiles = $sourcePath + './ArchivosCambiados/DiferenciasArchivosCambiados.xml'
$contentModifiedFiles = Get-Content -Path $sourcePathChangedFiles
PrintModifiedFiles -contentFile $contentModifiedFiles
if(-not ($null -eq $contentModifiedFiles)){
    $filesCopied = FilterAndCopyFiles $contentModifiedFiles $sourcePath $targetPath
    #Write-Host "Total de Archivos a Publicar:  $($filesCopied.result)" -ForegroundColor Yellow
    if($filesCopied.result -le 0){
        Write-Error ("No se encontraron archivos para desplegar")
    }
}else{
     Write-Error "No existe diferencias de archivos"
}