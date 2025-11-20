#!/bin/bash

Origen="/home"

Destino="/bacEneko"

Semana=$(date +%V)

Nombre="CopDifSem-$Semana.tar.gz"

tar -czg $Destino/snapshot.file -f $Destino/$Nombre $Origen
