#!/bin/bash

# --- Configuración ---
dimensiones=(16000 64000 128000 192000 256000)
hilos=(2 4 8 16 32)
iteraciones=10

# --- Compilación ---
echo "Compilando JacobiOMP sin optimización..."
gcc JacobiOMP.c -o JacobiOMP -fopenmp

echo "Compilando JacobiOMP con optimización -O3..."
gcc JacobiOMP.c -o JacobiOMP_O3 -fopenmp -O3

echo "Compilando JacobiSec..."
gcc JacobiSec.c -o JacobiSec

# --- Inicializar archivos CSV ---
echo "Dimension,Hilos,Iteracion,Tiempo" > ResultadosOMP.csv
echo "Dimension,Hilos,Iteracion,Tiempo" > ResultadosOMP_O3.csv
echo "Dimension,Iteracion,Tiempo" > ResultadosSEQ.csv

# --- Pruebas JacobiOMP sin optimización ---
echo "Ejecutando JacobiOMP sin optimización..."
for d in "${dimensiones[@]}"; do
    for h in "${hilos[@]}"; do
        for ((i=1; i<=iteraciones; i++)); do
            tiempo=$(./JacobiOMP $d $d $h)
            echo "$d,$h,$i,$tiempo" >> ResultadosOMP.csv
        done
    done
done

# --- Pruebas JacobiOMP con optimización -O3 ---
echo "Ejecutando JacobiOMP con optimización -O3..."
for d in "${dimensiones[@]}"; do
    for h in "${hilos[@]}"; do
        for ((i=1; i<=iteraciones; i++)); do
            tiempo=$(./JacobiOMP_O3 $d $d $h)
            echo "$d,$h,$i,$tiempo" >> ResultadosOMP_O3.csv
        done
    done
done

# --- Pruebas JacobiSec ---
echo "Ejecutando JacobiSec (secuencial)..."
for d in "${dimensiones[@]}"; do
    for ((i=1; i<=iteraciones; i++)); do
        tiempo=$(./JacobiSec $d $d)
        echo "$d,$i,$tiempo" >> ResultadosSEQ.csv
    done
done

echo "✅ Pruebas finalizadas. Resultados guardados en ResultadosOMP.csv, ResultadosOMP_O3.csv y ResultadosSEQ.csv"
