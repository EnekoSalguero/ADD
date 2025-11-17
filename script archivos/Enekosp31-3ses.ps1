# Declaración de parámetros: fecha inicio y fecha fin
param (
    [datetime]$FechaInicio,
    [datetime]$FechaFin
)

# Si la fecha de inicio NO fue introducida como parámetro, pedirla
if (-not $FechaInicio) {
    $FechaInicio = Read-Host "Introduce la fecha de inicio (ej: yyyy-mm-dd)"
}

# Si la fecha de fin NO fue introducida como parámetro, pedirla
if (-not $FechaFin) {
    $FechaFin = Read-Host "Introduce la fecha de fin (ej: yyyy-mm-dd)"
}

# Mostrar mensaje con el rango de fechas
Write-Host "`nMostrando inicios de sesión entre $FechaInicio y $FechaFin`n"

# Buscar eventos de inicio de sesión (ID 4624)
Get-WinEvent -FilterHashtable @{
    LogName   = 'Security'     # Registro de seguridad
    Id        = 4624           # ID del evento de inicio de sesión
    StartTime = $FechaInicio   # Fecha de inicio
    EndTime   = $FechaFin      # Fecha de fin
} |
# Filtrar para que NO aparezca el usuario SYSTEM
Where-Object {
    $_.Properties[5].Value -ne "SYSTEM"
} |
# Mostrar solo la fecha y el usuario que inició sesión
Select-Object @{Name="Fecha";Expression={$_.TimeCreated}},
              @{Name="Usuario";Expression={$_.Properties[5].Value}} |
# Formato tabla para que quede ordenado
Format-Table -AutoSize
