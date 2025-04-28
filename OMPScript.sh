#!/bin/bash

# --- Configuración ---
dimensiones=(16000 64000 128000 192000 256000)
hilos=(2 4 8 16 32)
iteraciones=10

# --- Compilación ---
echo "Compilando versión secuencial..."
gcc JacobiSec.c -o JacobiSec
if [ $? -ne 0 ]; then
    echo "Error en la compilación de JacobiSec.c. Abortando..."
    exit 1
fi

echo "Compilando versión OpenMP sin optimización..."
gcc JacobiOMP.c -o JacobiOMP -fopenmp
if [ $? -ne 0 ]; then
    echo "Error en la compilación de JacobiOMP.c. Abortando..."
    exit 1
fi

echo "Compilando versión OpenMP con optimización -O3..."
gcc JacobiOMP.c -o JacobiOMP_O3 -fopenmp -O3
if [ $? -ne 0 ]; then
    echo "Error en la compilación de JacobiOMP.c con optimización. Abortando..."
    exit 1
fi

# --- Inicializar archivos CSV ---
echo "Dimension,Iteracion,Tiempo" > ResultadosJacobiSec.csv
echo "Dimension,Hilos,Iteracion,Tiempo" > ResultadosJacobiOMP.csv
echo "Dimension,Hilos,Iteracion,Tiempo" > ResultadosJacobiOMP_O3.csv

# --- Pruebas Secuenciales ---
echo "Ejecutando pruebas secuenciales..."
for d in "${dimensiones[@]}"; do
    for ((i=1; i<=iteraciones; i++)); do
        tiempo=$( (time ./JacobiSec $d $d) 2>&1 | grep real | awk '{print $2}' | sed 's/m//; s/s//')
        echo "$d,$i,$tiempo" >> ResultadosJacobiSec.csv
    done
done

# --- Pruebas OpenMP sin optimización ---
echo "Ejecutando pruebas OpenMP sin optimización..."
for d in "${dimensiones[@]}"; do
    for h in "${hilos[@]}"; do
        export OMP_NUM_THREADS=$h
        for ((i=1; i<=iteraciones; i++)); do
            tiempo=$( (time ./JacobiOMP $d $i $h) 2>&1 | grep real | awk '{print $2}' | sed 's/m//; s/s//')
            echo "$d,$h,$i,$tiempo" >> ResultadosJacobiOMP.csv
        done
    done
done

# --- Pruebas OpenMP con optimización -O3 ---
echo "Ejecutando pruebas OpenMP con optimización -O3..."
for d in "${dimensiones[@]}"; do
    for h in "${hilos[@]}"; do
        export OMP_NUM_THREADS=$h
        for ((i=1; i<=iteraciones; i++)); do
            tiempo=$( (time ./JacobiOMP_O3 $d $i $h) 2>&1 | grep real | awk '{print $2}' | sed 's/m//; s/s//')
            echo "$d,$h,$i,$tiempo" >> ResultadosJacobiOMP_O3.csv
        done
    done
done

echo "✅ Pruebas completadas. Resultados en ResultadosJacobiSec.csv, ResultadosJacobiOMP.csv y ResultadosJacobiOMP_O3.csv"
