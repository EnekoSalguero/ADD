# === FUNCIONES ===

function pizza {
   Write-Host "1. Vegetariana"
Write-Host "2. No vegetariana"

$tipo = Read-Host "Elige tipo de pizza"

if ($tipo -eq "1") {
    Write-Host "Ingredientes: 1. Pimiento  2. Tofu"
    $ing = Read-Host "Elige ingrediente"
    if ($ing -eq "1") { $ingrediente = "Pimiento" }
    else { $ingrediente = "Tofu" }
    $tipoPizza = "Vegetariana"
}
else {
    Write-Host "Ingredientes: 1. Peperoni  2. Jamon  3. Salmon"
    $ing = Read-Host "Elige ingrediente"
    if ($ing -eq "1") { $ingrediente = "Peperoni" }
    elseif ($ing -eq "2") { $ingrediente = "Jamon" }
    else { $ingrediente = "Salmon" }
    $tipoPizza = "No vegetariana"
}

Write-Host "Tu pizza es $tipoPizza con mozzarella, tomate y $ingrediente"

}

function dias {
    $meses = @{
    "Enero" = 31
    "Febrero" = 29
    "Marzo" = 31
    "Abril" = 30
    "Mayo" = 31
    "Junio" = 30
    "Julio" = 31
    "Agosto" = 31
    "Septiembre" = 30
    "Octubre" = 31
    "Noviembre" = 30
    "Diciembre" = 31
}

$diasPares = 0
$diasImpares = 0

foreach ($mes in $meses.Keys) {
    for ($dia = 1; $dia -le $meses[$mes]; $dia++) {
        if ($dia % 2 -eq 0) {
            $diasPares++
        }
        else {
            $diasImpares++
        }
    }
}

Write-Host "Días pares: $diasPares"
Write-Host "Días impares: $diasImpares"
}

function usuarios {
function listar-usuarios {
    Get-LocalUser | Select-Object Name, Enabled
}

function crear-usuario {
    $usuario = Read-Host "Ingrese el nombre del nuevo usuario"
    $contra = Read-Host "Ingrese la contraseña" -AsSecureString

        New-LocalUser -Name $usuario -Password $contra
        Write-Host "Usuario '$usuario' creado correctamente."
}

function eliminar-usuario {
    $usuario = Read-Host "Ingrese el nombre del usuario a eliminar"

        Remove-LocalUser -Name $usuario
        Write-Host "Usuario '$usuario' eliminado correctamente."
}

function modificar-usuario {
    $usuario = Read-Host "Ingrese el nombre del usuario a modificar"
    $nuevoNombre = Read-Host "Ingrese el nuevo nombre de usuario"

        Rename-LocalUser -Name $usuario -NewName $nuevoNombre
        Write-Host "Usuario '$usuario' renombrado a '$nuevoNombre'."
}

do {
    Write-Host "MENU DE USUARIOS"
    Write-Host "1. Listar usuarios"
    Write-Host "2. Crear usuario"
    Write-Host "3. Eliminar usuario"
    Write-Host "4. Modificar usuario"
    Write-Host "5. Salir"
    $opcion = Read-Host "Seleccione una opción"

    switch ($opcion) {
        "1" { listar-usuarios }
        "2" { crear-usuario }
        "3" { eliminar-usuario }
        "4" { modificar-usuario }
        "5" { write-host "Saliendo" }
    }
} while ($opcion -ne "5")
}


function grupos {

Import-Module ActiveDirectory

function listar-grupos {
    $grupos = Get-ADGroup -Filter *
    foreach ($g in $grupos) {
        Write-Host "Grupo:" $g.Name
        Get-ADGroupMember -Identity $g.Name | ForEach-Object {
            Write-Host "  - Miembro:" $_.SamAccountName
        }
        Write-Host ""
    }
}

function crear-grupo {
    $grupo = Read-Host "Ingrese el nombre del nuevo grupo"
    New-ADGroup -Name $grupo -GroupScope Global -GroupCategory Security
    Write-Host "Grupo '$grupo' creado correctamente en AD."
}

function eliminar-grupo {
    $grupo = Read-Host "Ingrese el nombre del grupo a eliminar"
    Remove-ADGroup -Identity $grupo -Confirm:$false
    Write-Host "Grupo '$grupo' eliminado correctamente de AD."
}

function agregar-miembro {
    $grupo = Read-Host "Ingrese el nombre del grupo"
    $usuario = Read-Host "Ingrese el nombre del usuario a agregar"
    Add-ADGroupMember -Identity $grupo -Members $usuario
    Write-Host "Usuario '$usuario' agregado al grupo '$grupo' en AD."
}

function eliminar-miembro {
    $grupo = Read-Host "Ingrese el nombre del grupo"
    $usuario = Read-Host "Ingrese el nombre del usuario a eliminar"
    Remove-ADGroupMember -Identity $grupo -Members $usuario -Confirm:$false
    Write-Host "Usuario '$usuario' eliminado del grupo '$grupo' en AD."
}

do {
    Write-Host ""
    Write-Host "===== MENU DE GRUPOS (AD) ====="
    Write-Host "1. Listar grupos y miembros"
    Write-Host "2. Crear grupo"
    Write-Host "3. Eliminar grupo"
    Write-Host "4. Agregar miembro a grupo"
    Write-Host "5. Eliminar miembro de grupo"
    Write-Host "6. Salir"
    $opcion = Read-Host "Seleccione una opción"

    switch ($opcion) {
        "1" { listar-grupos }
        "2" { crear-grupo }
        "3" { eliminar-grupo }
        "4" { agregar-miembro }
        "5" { eliminar-miembro }
        "6" { Write-Host "Saliendo..." }
        default { Write-Host "Opción no válida" }
    }
} while ($opcion -ne "6")


}


function particiones {

# Pedir número de disco
$diskNum = Read-Host "Introduce el número de disco (ej. 1)"

# Obtener información del disco
$disk = Get-Disk -Number $diskNum

# Mostrar tamaño en GB
$tamGB = [math]::Round($disk.Size / 1GB, 2)
Write-Host "El disco $diskNum tiene un tamaño de $tamGB GB"

# Confirmar antes de limpiar
$confirm = Read-Host "¿Deseas limpiar el disco? (S/N)"
if ($confirm -ne "S") { Write-Host "Cancelado."; exit }

# Crear archivo temporal para Diskpart
$temp = "$env:TEMP\diskpart_script.txt"

# Limpiar el disco
@"
select disk $diskNum
clean
convert gpt
"@ | Out-File $temp -Encoding ASCII

# Ejecutar limpieza
diskpart /s $temp

# Crear particiones de 1GB hasta que no quede espacio
$free = $disk | Get-Disk | Get-PartitionSupportedSize
$tamRestante = $free.SizeMax
$cont = 1

while ($tamRestante -gt 1GB) {
    @"
select disk $diskNum
create partition primary size=1024
assign
"@ | Out-File $temp -Encoding ASCII
    diskpart /s $temp
    $tamRestante -= 1GB
    $cont++
}

Write-Host "Particiones de 1GB creadas correctamente en el disco $diskNum."

}



function contra {

$contraseña= read-host "Escribe la contra"

if ($contraseña -notmatch '[qwertyuiopasdfghjklñzxcvbnm]'){
write-host "vaya mierda"
break
}

if ($contraseña -notmatch '[QWERTYUIOPASDFGHJKLÑZXCVBNM]'){
write-host "vaya mierda"
break
}

if ($contraseña -notmatch '[1234567890]'){
write-host "vaya mierda"
break
}

if ($contraseña -notmatch '[.,-_]'){
write-host "vaya mierda"
break
}


if ($contraseña.Length -ge 8){
Write-Host "buena"
break
}

write-host "vaya mierda"

}




function fibo {

$num= Read-Host "cuantos numeros de fibonacci quieres?"
$vueltas = 0
$numero1 = 0
$numero2 = 1
$resul = "0 1 "


while ($vueltas -lt ($num - 2)){

  if ($numero1 -le $numero2){
   $suma = $numero1 + $numero2
   $numero1 = $suma
   $resul += "$suma "
  }
  else {
   $suma = $numero1 + $numero2
   $numero2 = $suma
   $resul += "$suma "
  }
  
  $vueltas++

}

write-host "$resul"

}



function fibo2 {

$nu = Read-Host "cuantos numeros quieres del fibonacci?"


function fibonac($n) {
      if ($n -lt 2) {
        return $n
      }
      else {
        return (fibonac ($n - 1)) + (fibonac ($n - 2))
      }


}

for ($i = 0; $i -lt $nu; $i++) {
    Write-Host "fibonacci($i) = $(fibonac $i)"
}


}






function cpu {


$i = 0
$numeros = 0

while ($i -lt 6) {
$uso = (Get-CimInstance Win32_Processor).LoadPercentage
Start-Sleep -Seconds 5

Write-Host "Uso de la CPU: ",$uso

$numeros = $numeros + $uso


$i++
}


$media = $numeros / 6
Write-Host "la media es: $media"



}



function espacio {

# Revisar todas las unidades del sistema
Get-PSDrive -PSProvider FileSystem | ForEach-Object {
    $unidad = $_.Name
    $libre = $_.Free
    $total = $_.Used + $_.Free
    $porcentaje = [math]::Round(($libre / $total) * 100, 2)

    if ($porcentaje -lt 10) {
         
        Write-Host "La unidad $unidad tiene solo $porcentaje% libre."
        Add-Content -Path $log -Value "$(Get-Date) - $mensaje"
    }
}


}




function clonar {

# Carpeta destino de las copias
$destino = "C:\CopiasSeguridad"

# Crear carpeta si no existe
if (-not (Test-Path $destino)) {
    New-Item -Path $destino -ItemType Directory | Out-Null
    Write-Host "Carpeta '$destino' creada."
}

# Recorrer cada carpeta de usuario en C:\Users
Get-ChildItem "C:\Users" -Directory | ForEach-Object {
    $usuario = $_.Name
    $origen = $_.FullName
    $zip = Join-Path $destino "$usuario.zip"

    Write-Host "Creando copia de $usuario ..."

    # Comprimir el perfil del usuario
    Compress-Archive -Path $origen -DestinationPath $zip -Force
}

Write-Host "copias de seguridad creadas en $destino"

}



# === MENÚ PRINCIPAL ===

do {
    Write-Host ""
    Write-Host "===== MENU PRINCIPAL ====="
    Write-Host "0. Salir"
    Write-Host "1. Pizza"
    Write-Host "2. Días pares e impares"
    Write-Host "3. usuarios"
    Write-Host "4. grupos"
    Write-Host "5. particiones"
    Write-Host "6. contraseña"
    Write-Host "7. fibonacci"
    Write-Host "8. fibonacci2"
    Write-Host "9. cpu"
    Write-Host "10. espacio"
    Write-Host "11. clonar"
    $opcion = Read-Host "Seleccione una opción"

    switch ($opcion) {
        "0" {Write-Host "Saliendo..."}
        "1" { pizza }
        "2" { dias}
        "3" { usuarios }
        "4" { grupos }
        "5" { particiones }
        "6" { contra }
        "7" { fibo }
        "8" { fibo2 }
        "9" { cpu }
        "10" { espacio }
        "11" { clonar }
        default { Write-Host "Opción no válida." }
    }
} while ($opcion -ne "0")



