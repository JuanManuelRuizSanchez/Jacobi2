#!/bin/bash

# Dimensión fija
DIM=64000
SWEEPS=64000

# Iteraciones por configuración
ITER=10

# Archivo de salida
OUTPUT="ResultadosOptimizacionJacobi.csv"
echo "Optimizacion,Iteracion,Tiempo" > "$OUTPUT"

# Compilaciones con diferentes niveles de optimización
for opt in O1 O2 O3; do
    gcc JacobiSec.c -o JacobiSec_${opt} -${opt}
    
    for ((i=1; i<=ITER; i++)); do
        tiempo=$(./JacobiSec_${opt} "$DIM" "$SWEEPS")
        echo "$opt,$i,$tiempo" >> "$OUTPUT"
    done
done

echo "✅ Pruebas completadas. Resultados en $OUTPUT"
