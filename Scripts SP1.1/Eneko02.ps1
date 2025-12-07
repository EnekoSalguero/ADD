param( 
[switch]$G,
[switch]$U,
[switch]$M,
[switch]$AG,
[switch]$LIST,
[string]$Param2,
[string]$Param3,
[string]$Param4,
[switch]$DryRun     
)

# función para ejecución real o simulada hecha por ia
function Ejecutar { param($ComandoDesc, $ScriptBlock)      
 if ($DryRun) {                                        
  write-host "[DRY RUN] $ComandoDesc"             
 } else {                                         
  & $ScriptBlock                                    
 }                                                   
}                                                          


function Mostrar-Ayuda {
write-host "debes indicar una accion. acciones disponibles:"
write-host "-G    crear grupo. parametros: NombreGrupo Ambito(Global/Universal/Local) Tipo(Seguridad/Distribucion)"
write-host "-U    crear usuario. parametros: NombreUsuario UnidadOrganizativa"
write-host "-M    modificar usuario. parametros: NombreUsuario NuevaContrasen (habilitar/deshabilitar)"
write-host "-AG   asignar usuario a grupo. parametros: NombreUsuario NombreGrupo"
write-host "-LIST listar objetos. parametros: (Usuarios/Grupos/Ambos) (UO opcional)"
write-host "--dryrun muestra lo que se haria sin ejecutar"  
}



function Crear-Grupo {
 param($NombreGrupo, $Ambito, $Tipo)

 $grupo = get-adgroup -filter "Name -eq '$NombreGrupo'" -erroraction silentlycontinue


 if ($grupo) {
  write-host "el grupo '$NombreGrupo' ya existe."
 } 
 else {

  Ejecutar "Creación de grupo $NombreGrupo" { new-adgroup -name $NombreGrupo -groupscope $Ambito -groupcategory $Tipo }  

  write-host "grupo '$NombreGrupo' creado correctamente."
  }
}




function Crear-Usuario {
 param(
  [string]$Nombre,
  [string]$UO
 )

# Obtener dominio
 $Dominio = (Get-ADDomain).DNSRoot
 $PartesDominio = $Dominio.Split('.')
 $RutaDominio = "DC=" + ($PartesDominio -join ",DC=")

# Si usan "Users" va como CN
 if ($UO -ieq "Users") {
  $UOPath = "CN=Users,$RutaDominio"
 }
 else {
  $UOPath = "OU=$UO,$RutaDominio"

# Crear OU si no existe
  if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$UO'" -ErrorAction SilentlyContinue)) {
   Ejecutar "Creación de OU $UO" {
    New-ADOrganizationalUnit -Name $UO -Path $RutaDominio
   }
   Write-Host "OU '$UO' creada automáticamente."
  }

 }

# Validar si usuario ya existe
 $user = Get-ADUser -Filter "SamAccountName -eq '$Nombre'" -ErrorAction SilentlyContinue
 if ($user) {
  Write-Host "El usuario '$Nombre' ya existe."
  return
 }

# Generar contraseña aleatoria
 $Pass = [Guid]::NewGuid().ToString().Substring(0,12)

# Crear usuario
 Ejecutar "Creación de usuario $Nombre en $UOPath" {
  New-ADUser -Name $Nombre -SamAccountName $Nombre -Path $UOPath -AccountPassword (ConvertTo-SecureString $Pass -AsPlainText -Force) -Enabled $true
 }

 Write-Host "Usuario '$Nombre' creado con contraseña: $Pass"
}





function Modificar-Usuario {
 param($Nombre, $NuevaPass, $Estado)

 $user = get-aduser -identity $Nombre -erroraction silentlycontinue

 if (-not $user) {
  write-host "el usuario '$Nombre' no existe."
  return
 }


    # comprobar complejidad basica
 if ($NuevaPass.Length -lt 8 -or 
  $NuevaPass -notmatch "[A-Z]" -or
  $NuevaPass -notmatch "[a-z]" -or
  $NuevaPass -notmatch "[0-9]") {

  write-host "la contrasena no cumple los requisitos minimos (8 caracteres, mayuscula, minuscula, numero)."
  return
 }
# cambiar contrasena

 Ejecutar "Cambiar contraseña del usuario $Nombre" { set-adaccountpassword -identity $Nombre -newpassword (convertto-securestring $NuevaPass -asplaintext -force) }  

 write-host "contrasena modificada correctamente."

# cambiar estado
 if ($Estado -eq "habilitar") {

  Ejecutar "Habilitar cuenta $Nombre" { enable-adaccount -identity $Nombre }   

  write-host "cuenta habilitada."
 } 
 elseif ($Estado -eq "deshabilitar") {

  Ejecutar "Deshabilitar cuenta $Nombre" { disable-adaccount -identity $Nombre }  

  write-host "cuenta deshabilitada."
 }
}





function Asignar-Grupo {
 param($Usuario, $Grupo)

 $user = get-aduser -identity $Usuario -erroraction silentlycontinue
 $grp = get-adgroup -identity $Grupo -erroraction silentlycontinue

 if (-not $user) {
  write-host "el usuario '$Usuario' no existe."
  return
 }

 if (-not $grp) {
  write-host "el grupo '$Grupo' no existe."
  return
 }

 Ejecutar "Añadir usuario $Usuario al grupo $Grupo" { add-adgroupmember -identity $Grupo -members $Usuario }   

 write-host "usuario '$Usuario' anadido al grupo '$Grupo'."
}





function Listar-Objetos {
 param($Tipo, $UO)

 $Dominio = (Get-ADDomain).DNSRoot
 $PartesDominio = $Dominio.Split('.')
 $RutaDominio = "DC=" + ($PartesDominio -join ",DC=")

# Si hay UO y es Users → CN, si no → OU
 if ($UO) {
  if ($UO -ieq "Users") {
   $SearchBase = "CN=Users,$RutaDominio"
  } 
  else {
   $SearchBase = "OU=$UO,$RutaDominio"
  }
 } 
 else {
  $SearchBase = $null
 }



 if ($Tipo -eq "Usuarios" -or $Tipo -eq "Ambos") {
  if ($SearchBase) {
   Get-ADUser -Filter * -SearchBase $SearchBase | Select Name | Sort Name
  } 
  else {
   Get-ADUser -Filter * | Select Name | Sort Name
  }
 }

 if ($Tipo -eq "Grupos" -or $Tipo -eq "Ambos") {
  if ($SearchBase) {
   Get-ADGroup -Filter * -SearchBase $SearchBase | Select Name | Sort Name
  } 
  else {
   Get-ADGroup -Filter * | Select Name | Sort Name
  }
 }
}




if ($G) {
 Crear-Grupo -NombreGrupo $Param2 -Ambito $Param3 -Tipo $Param4
} 
elseif ($U) {
 Crear-Usuario -Nombre $Param2 -UO $Param3
} 
elseif ($M) {
 Modificar-Usuario -Nombre $Param2 -NuevaPass $Param3 -Estado $Param4
} 
elseif ($AG) {
 Asignar-Grupo -Usuario $Param2 -Grupo $Param3
} 
elseif ($LIST) {
 Listar-Objetos -Tipo $Param2 -UO $Param3
} 
else {
 Mostrar-Ayuda
}
