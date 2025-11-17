# Bucle DO..UNTIL para que el menú se repita hasta que el usuario pulse 0
do {

    Clear-Host   # Limpia la pantalla cada vez que se muestra el menú

    # Mostrar el menú
    Write-Host "---MENU DE EVENTOS---"
    Write-Host "1 - Listado de eventos del sistema"
    Write-Host "2 - Errores del sistema del último mes"
    Write-Host "3 - Warnings de aplicaciones de esta semana"
    Write-Host "0 - Salir"

    # Leer la opción del usuario
    $opcion = Read-Host "Elige una opción"

    # Dependiendo de la opción, se ejecuta un bloque diferente
    switch ($opcion) {

        "1" {
            # Mostrar los 20 eventos más recientes del registro System
            Write-Host "---LISTADO DE EVENTOS DEL SISTEMA---"
            Get-EventLog -LogName System -Newest 20
            pause   # Pausa para que el usuario vea la información
        }

        "2" {
            # Mostrar errores del registro System del último mes
            Write-Host "--- ERRORES DEL ÚLTIMO MES ---"

            # Restar 1 mes a la fecha actual
            $fecha = (Get-Date).AddMonths(-1)

            # Filtrar los errores cuyo TimeGenerated sea mayor a la fecha calculada
            Get-EventLog -LogName System -EntryType Error |
            Where-Object { $_.TimeGenerated -gt $fecha }

            pause   # Pausa para ver los resultados
        }

        "3" {
            # Mostrar warnings del registro Application de los últimos 7 días
            Write-Host "--- WARNINGS DE APLICACIONES DE ESTA SEMANA ---"

            # Restar 7 días a la fecha actual
            $fecha = (Get-Date).AddDays(-7)

            # Filtrar los warnings
            Get-EventLog -LogName Application -EntryType Warning |
            Where-Object { $_.TimeGenerated -gt $fecha }

            pause   # Pausa para ver la información
        }
    }

# El menú se repetirá hasta que la opción sea 0
} until ($opcion -eq "0")

