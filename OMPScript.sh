#!/bin/bash

# --- Configuración ---
dimensiones=(16000 64000 128000 192000 256000)
hilos=(2 4 8 16 32)
iteraciones=10

# --- Compilación ---
echo "Compilando versión secuencial..."
gcc JacobiSec.c -o JacobiSec

echo "Compilando versión OpenMP sin optimización..."
gcc JacobiOMP.c -o JacobiOMP -fopenmp

echo "Compilando versión OpenMP con optimización -O3..."
gcc JacobiOMP.c -o JacobiOMP_O3 -fopenmp -O3

# --- Inicializar archivos CSV ---
echo "Dimension,Iteracion,Tiempo" > ResultadosJacobiSec.csv
echo "Dimension,Hilos,Iteracion,Tiempo" > ResultadosJacobiOMP.csv
echo "Dimension,Hilos,Iteracion,Tiempo" > ResultadosJacobiOMP_O3.csv

# --- Pruebas Secuencial ---
echo "Ejecutando pruebas secuenciales..."
for d in "${dimensiones[@]}"; do
    for ((i=1; i<=iteraciones; i++)); do
        tiempo=$(./JacobiSec $d $d)
        echo "$d,$i,$tiempo" >> ResultadosJacobiSec.csv
    done
done

# --- Pruebas OpenMP sin optimización ---
echo "Ejecutando pruebas OpenMP sin optimización..."
for d in "${dimensiones[@]}"; do
    for h in "${hilos[@]}"; do
        for ((i=1; i<=iteraciones; i++)); do
            export OMP_NUM_THREADS=$h
            tiempo=$(./JacobiOMP $d $d)
            echo "$d,$h,$i,$tiempo" >> ResultadosJacobiOMP.csv
        done
    done
done

# --- Pruebas OpenMP con optimización -O3 ---
echo "Ejecutando pruebas OpenMP con optimización -O3..."
for d in "${dimensiones[@]}"; do
    for h in "${hilos[@]}"; do
        for ((i=1; i<=iteraciones; i++)); do
            export OMP_NUM_THREADS=$h
            tiempo=$(./JacobiOMP_O3 $d $d)
            echo "$d,$h,$i,$tiempo" >> ResultadosJacobiOMP_O3.csv
        done
    done
done

echo "✅ Pruebas completadas. Resultados en ResultadosJacobiSec.csv, ResultadosJacobiOMP.csv y ResultadosJacobiOMP_O3.csv"
