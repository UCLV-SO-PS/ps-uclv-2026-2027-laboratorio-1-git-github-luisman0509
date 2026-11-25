#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <pwd.h>
#include <sys/sysinfo.h>

void mostrar_info_sistema(void) {
    printf("=== Monitor de Procesos del Sistema ===\n");
    printf("Versión: 1.0\n");
    struct passwd *pw = getpwuid(getuid());
    if (pw != NULL) {
        printf("Usuario: %s\n", pw->pw_name);
    }

    printf("PID del proceso: %ld\n", (long)getpid());
    printf("PID del proceso padre: %ld\n", (long)getppid());
}

int mostrar_uso_memoria(void) {
    struct sysinfo info;

    printf("--- Información de Memoria ---\n");

    if (sysinfo(&info) != 0) {
        perror("No se pudo consultar la memoria");
        return 1;
    }

    unsigned long long total =
        (unsigned long long)info.totalram * info.mem_unit;
    unsigned long long libre =
        (unsigned long long)info.freeram * info.mem_unit;
    const unsigned long long mib = 1024ULL * 1024ULL;

    printf("Memoria total: %llu MiB\n", total / mib);
    printf("Memoria libre: %llu MiB\n", libre / mib);
    printf("Memoria utilizada (total - libre): %llu MiB\n",
           (total - libre) / mib);

    return 0;
}

int main(void) {
    mostrar_info_sistema();
    return mostrar_uso_memoria();
}
