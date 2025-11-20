#!/bin/bash

Origen="/home"
Destino="/bacEneko"

Mes=$(date +"%B")
Ano=$(date +"%Y")

Nombre="CopTot-$Mes-$Ano.tar.gz"

tar -czf $Destino/$Nombre $Origen
