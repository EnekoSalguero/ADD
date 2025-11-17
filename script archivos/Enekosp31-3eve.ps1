# Obtener todos los tipos de registros de eventos disponibles en el sistema
$tipos = Get-EventLog -List

# Bucle que muestra el menú hasta que el usuario elija 0
do {
    Clear-Host  # Limpia la pantalla

    Write-Host "---MENU DE TIPOS DE REGISTROS---"
    
    # Mostrar la lista de tipos numerados
    $i = 1
    foreach ($t in $tipos) {
        Write-Host "$i - $($t.Log)"   # Mostrar número y nombre del log
        $i++
    }

    Write-Host "0 - Salir"

    # Leer la opción que escribe el usuario
    $opcion = Read-Host "Elige una opción"

    # Si la opción NO es 0, mostramos los logs
    if ($opcion -ne "0") {

        # Convertir la opción a índice (restar 1 porque la lista empieza en 0)
        $index = [int]$opcion - 1

        # Obtener el nombre del log usando el índice
        $log = $tipos[$index].Log

        Write-Host "`nMostrando los 12 últimos registros de: $log`n"

        # Mostrar los 12 eventos más recientes del tipo seleccionado
        Get-EventLog -LogName $log -Newest 12

        Pause  # Pausa para que el usuario pueda ver los resultados
    }

# El menú se repite hasta que la opción sea 0
} until ($opcion -eq "0")
