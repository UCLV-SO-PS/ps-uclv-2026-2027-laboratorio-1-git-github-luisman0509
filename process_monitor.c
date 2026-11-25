#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <pwd.h>

void mostrar_info_sistema(void) {
    printf("=== Monitor de Procesos del Sistema ===\n");

    struct passwd *pw = getpwuid(getuid());
    if (pw != NULL) {
        printf("Usuario: %s\n", pw->pw_name);
    }

    printf("PID del proceso: %ld\n", (long)getpid());
    printf("PID del proceso padre: %ld\n", (long)getppid());
}

void mostrar_uso_memoria(void) {
    printf("--- Información de Memoria ---\n");
    printf("Funcionalidad de memoria por implementar\n");
}

int main(void) {
    mostrar_info_sistema();
    mostrar_uso_memoria();
    return 0;
}
