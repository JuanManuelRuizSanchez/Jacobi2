#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <omp.h> // Incluimos OpenMP

// Función para medir tiempo en segundos
double get_time() {
    struct timeval t;
    gettimeofday(&t, NULL);
    return t.tv_sec + t.tv_usec / 1e6;
}

// Implementación paralela de Jacobi 1D con OpenMP
void jacobi_omp(int nsweeps, int n, double* u, double* f) {
    int sweep;
    double h = 1.0 / n;
    double h2 = h * h;
    double* utmp = (double*) malloc((n + 1) * sizeof(double));

    if (!utmp) {
        perror("Error al reservar memoria para utmp");
        exit(EXIT_FAILURE);
    }

    utmp[0] = u[0];
    utmp[n] = u[n];

    for (sweep = 0; sweep < nsweeps; sweep += 2) {
        // Primer barrido: actualizar utmp en paralelo
        #pragma omp parallel for
        for (int i = 1; i < n; i++) {
            utmp[i] = (u[i - 1] + u[i + 1] + h2 * f[i]) / 2.0;
        }

        // Segundo barrido: actualizar u en paralelo
        #pragma omp parallel for
        for (int i = 1; i < n; i++) {
            u[i] = (utmp[i - 1] + utmp[i + 1] + h2 * f[i]) / 2.0;
        }
    }

    free(utmp);
}

int main(int argc, char** argv) {
    if (argc != 4) {
        fprintf(stderr, "Uso: %s <n> <nsweeps> <nthreads>\n", argv[0]);
        return EXIT_FAILURE;
    }

    int n = atoi(argv[1]);
    int nsweeps = atoi(argv[2]);
    int nthreads = atoi(argv[3]);

    if (n <= 0 || nsweeps <= 0 || nthreads <= 0) {
        fprintf(stderr, "Error: Parámetros inválidos\n");
        return EXIT_FAILURE;
    }

    omp_set_num_threads(nthreads); // Fijamos la cantidad de hilos

    double *u = (double*) malloc((n + 1) * sizeof(double));
    double *f = (double*) malloc((n + 1) * sizeof(double));

    if (!u || !f) {
        perror("Error en la asignación de memoria");
        return EXIT_FAILURE;
    }

    u[0] = 0.0;
    u[n] = 0.0;
    for (int i = 1; i < n; i++) {
        u[i] = 0.0;
    }

    double h = 1.0 / n;
    for (int i = 0; i <= n; i++) {
        f[i] = i * h;
    }

    double t0 = get_time();
    jacobi_omp(nsweeps, n, u, f);
    double t1 = get_time();

    printf("%.6f\n", t1 - t0);

    free(u);
    free(f);
    return EXIT_SUCCESS;
}
