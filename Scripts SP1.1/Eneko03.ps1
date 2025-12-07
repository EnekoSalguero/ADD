param(
 [string]$Fichero,
 [switch]$DryRun
)



# Validación del parámetro
if ([string]::IsNullOrWhiteSpace($Fichero)) {
 Write-Host "ERROR: Debes indicar un fichero como parámetro. Ejemplo:"
 Write-Host "       .\script.ps1 bajas.txt"
 exit
}

Import-Module ActiveDirectory





# Validar que el fichero existe y es un archivo
if (-not (Test-Path $Fichero)) {
 Write-Host "ERROR: El fichero especificado no existe."
 exit
}


if ((Get-Item $Fichero).PsIsContainer) {
 Write-Host "ERROR: El parámetro debe ser un fichero, no una carpeta."
 exit
}


# Rutas
$LogDir      = "C:\Logs"
$ProyectoDir = "C:\Users\proyecto"

# Crear carpetas
if (-not $DryRun) {
 if (!(Test-Path $LogDir))      { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
 if (!(Test-Path $ProyectoDir)) { New-Item -ItemType Directory -Path $ProyectoDir -Force | Out-Null }
} else {
 Write-Host "[DRYRUN] Se crearían las carpetas $LogDir y $ProyectoDir si no existieran"
}

$LogErrores = "$LogDir\bajaserror.log"
$LogOK      = "$LogDir\bajas.log"

#dryrun hecho con ia
$Simulacion = @()
if ($DryRun) {
 $Simulacion += "EJECUCIÓN EN MODO DRYRUN"
 $Simulacion += "--------------------------------------"
}



# Procesar el fichero línea a línea
Get-Content $Fichero | ForEach-Object {

 $p = $_.Split(":")
  if ($p.Count -lt 4) {
   if ($DryRun) {
    $Simulacion += "Línea mal formada: $_"
   } 
   else {
    Add-Content $LogErrores "$(Get-Date) - ERROR: línea mal formada -> $_"
   }
   return
  }

 $nombre = $p[0]
 $ape1   = $p[1]
 $ape2   = $p[2]
 $login  = $p[3].Trim()


# Buscar usuario en AD
 try {
  $usuario = Get-ADUser -Identity $login -ErrorAction Stop
 if ($DryRun) { $Simulacion += "Encontrado usuario AD: $login" }
 } 
 catch {
  if ($DryRun) {
   $Simulacion += "Usuario NO encontrado en AD: $login"
  } 
  else {
   Add-Content $LogErrores "$(Get-Date) - $login - Usuario no existe"
  }
  return
 }



# Carpetas
 $CarpetaDestino = Join-Path $ProyectoDir $login
 $Perfil  = "C:\Users\$login"
 $Trabajo = "$Perfil\trabajo"

# Crear carpeta destino
 if ($DryRun) {
  $Simulacion += "Se crearía: $CarpetaDestino"
 } 
 else {
  if (!(Test-Path $CarpetaDestino)) {
   New-Item -ItemType Directory -Path $CarpetaDestino -Force | Out-Null
  }
 }


# Validar perfil
 if (!(Test-Path $Perfil)) {
  if ($DryRun) { 
   $Simulacion += "El perfil local no existe: $Perfil"
  } 
  else {
   Add-Content $LogErrores "$(Get-Date) - $login - Perfil local no existe"
  }
  return
 }




# Validar carpeta trabajo
 if (!(Test-Path $Trabajo)) {
  if ($DryRun) { 
   $Simulacion += "La carpeta trabajo no existe: $Trabajo"
  } 
  else {
   Add-Content $LogErrores "$(Get-Date) - $login - Carpeta trabajo no existe"
  }
  return
 }




# Mover ficheros
 $Ficheros = Get-ChildItem $Trabajo -File

 if ($DryRun) {
  $Simulacion += "Se moverían $($Ficheros.Count) ficheros a $CarpetaDestino"
 } 
 else {
  $log = @()
  $log += "============================================="
  $log += "$(Get-Date) - LOGIN: $login"
  $log += "Carpeta destino: $CarpetaDestino"
  $log += "Ficheros movidos:"

  $i = 1
  foreach ($f in $Ficheros) {
   try {
    Move-Item $f.FullName -Destination $CarpetaDestino -Force
    $log += "$i - $($f.Name)"
    $i++
   }
   catch {
    Add-Content $LogErrores "$(Get-Date) - $login - Error moviendo fichero $($f.Name)"
   }
  }

  $log += "TOTAL FICHEROS: $( $i - 1 )"
  $log += "============================================="

  Add-Content $LogOK -Value $log
 }




# Cambiar propietario
 if ($DryRun) {
  $Simulacion += "Se cambiaría el propietario de $CarpetaDestino"
 } 
 else {
  try {
   takeown /F "$CarpetaDestino*" /A | Out-Null
   icacls $CarpetaDestino /setowner "Administrador" /T | Out-Null
  } 
  catch {
   Add-Content $LogErrores "$(Get-Date) - $login - Error cambiando propietario"
  }
 }


# Eliminar usuario AD
 if ($DryRun) {
  $Simulacion += "Se eliminaría el usuario AD: $login"
 } 
 else {
  try {
   emove-ADUser -Identity $login -Confirm:$false -ErrorAction Stop
  } 
  catch {
   Add-Content $LogErrores "$(Get-Date) - $login - Error eliminando usuario AD"
  }
 }




# Eliminar perfil local
 if ($DryRun) {
  $Simulacion += "Se eliminaría el perfil local: $Perfil"
 } 
 else {
  if (Test-Path $Perfil) {
   try {
    Remove-Item $Perfil -Recurse -Force -ErrorAction Stop
   } 
   catch {
    Add-Content $LogErrores "$(Get-Date) - $login - Error eliminando perfil local"
   }
  }
 }
}




# Mostrar resumen dryrun hecho con ia
if ($DryRun) {
 Write-Host "========== SIMULACIÓN =========="
 $Simulacion | ForEach-Object { Write-Host $_ }
 Write-Host "================================"
} 
else {

 Write-Host "El script se ha ejecutado correctamente."
}
