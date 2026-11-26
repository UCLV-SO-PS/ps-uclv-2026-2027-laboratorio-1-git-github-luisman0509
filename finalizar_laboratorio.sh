#!/usr/bin/env bash
# Completa los pasos pendientes desde el commit de fusión revisado.
# Ejecutar en la raíz del repositorio: bash finalizar_laboratorio.sh
set -euo pipefail

fallar() {
    printf '\nNo se pudo continuar: %s\n' "$1" >&2
    exit 1
}

for herramienta in git gcc make python3; do
    command -v "$herramienta" >/dev/null || fallar "Falta $herramienta."
done

test -f process_monitor.c && test -f Makefile ||
    fallar "Ejecuta el script en la carpeta del laboratorio."
test -f finalizar_laboratorio.sh ||
    fallar "Guarda el script como finalizar_laboratorio.sh en esta carpeta."
test "$(git branch --show-current)" = main || fallar "La rama actual debe ser main."
git diff --quiet && git diff --cached --quiet ||
    fallar "Hay cambios sin guardar. Compártelos antes de continuar."

# Esta variable solo se modifica al probar el script en un repositorio temporal.
esperado="${LAB_HEAD_ESPERADO:-d73fc2e}"
test "$(git rev-parse HEAD)" = "$(git rev-parse "$esperado^{commit}")" ||
    fallar "El último commit ya no es el punto de partida esperado; no repitas los pasos."

while IFS= read -r -d '' archivo; do
    test "$archivo" = finalizar_laboratorio.sh ||
        fallar "Hay un archivo sin seguimiento que hay que revisar: $archivo"
done < <(git ls-files --others --exclude-standard -z)

git remote get-url origin >/dev/null || fallar "No está configurado origin."

printf '\n1. Comprobando que el programa actual compila.\n'
make clean
make
./process_monitor

printf '\n2. Eliminando las ramas que ya están fusionadas.\n'
for rama in feature-memoria feature-nueva-funcionalidad feature-nueva-funcionalidad-conflicto; do
    if git show-ref --verify --quiet "refs/heads/$rama"; then
        git branch -d "$rama"
    fi
done

printf '\n3. Registrando el cambio de versión del ejercicio.\n'
python3 - <<'PY'
from pathlib import Path
archivo = Path('process_monitor.c')
texto = archivo.read_text(encoding='utf-8')
anterior = 'printf("Versión: 2.0 -- Conflictiva --\\n");'
nueva = 'printf("Versión: 3.0 -- Cambio no deseado --\\n");'
if texto.count(anterior) != 1:
    raise SystemExit('No se encontró una única línea de versión 2.0. Revisa el archivo.')
archivo.write_text(texto.replace(anterior, nueva), encoding='utf-8')
PY
git add process_monitor.c
git commit -m "Cambio accidental"

printf '\n4. Deshaciendo ese cambio mediante un nuevo commit.\n'
git revert --no-edit HEAD

printf '\n5. Comprobando la compilación y la versión recuperada.\n'
make clean
make
salida="$(./process_monitor)"
printf '%s\n' "$salida"
if ! printf '%s\n' "$salida" | grep -Fq 'Versión: 2.0 -- Conflictiva --'; then
    fallar "La versión final no es la esperada. No se subirán los cambios."
fi

printf '\n6. Documentando el trabajo y el procedimiento de automatización.\n'
cat > README.md <<'DOC'
# Laboratorio 1: Git y GitHub

**Estudiante:** Luis Manuel Calero Barroso  
**Carrera:** Ciencias de la Computación, tercer año  
**Asignatura:** Programación de Sistemas

## Descripción

El proyecto consiste en un monitor sencillo escrito en C. Muestra el usuario
de Linux, el PID del programa, el PID de su padre y la memoria total y libre.
La memoria utilizada se calcula como la diferencia entre la total y la libre.

## Compilar y ejecutar

En Linux o en la terminal de Codespaces:

```bash
make
./process_monitor
```

Para eliminar el ejecutable generado:

```bash
make clean
```

Los resultados de memoria corresponden al sistema donde se ejecuta el programa.
En Codespaces no representan la memoria de la laptop. Se respeta `mem_unit`
al convertir los datos de `sysinfo()` a bytes y luego a MiB.

## Operaciones de Git practicadas

- Preparación de archivos y commits por etapas.
- Comparación de cambios con `git diff` y consulta del historial con `git log`.
- Creación de una rama para implementar la consulta de memoria y su fusión.
- Modificación de una misma línea en dos ramas y resolución del conflicto.
- Eliminación de las ramas que ya habían sido fusionadas.
- Registro de un cambio de versión y reversión mediante `git revert`.
- Envío del historial a GitHub con `git push`.

El ejercicio de reversión conserva tanto el commit del cambio como el que lo
deshace. Por eso la versión final vuelve a ser `2.0 -- Conflictiva --`.

## Script de apoyo

`finalizar_laboratorio.sh` automatiza los últimos pasos desde el commit de
fusión revisado. Comprueba el estado del repositorio, elimina las ramas
fusionadas, realiza el ejercicio de reversión, compila y envía los commits.
Solo debe ejecutarse una vez desde ese punto; no sirve para reiniciar el laboratorio.
La modificación temporal a versión 3.0 es deliberada para practicar `revert`.
DOC

git add README.md finalizar_laboratorio.sh
git commit -m "Documentar el laboratorio y su script de apoyo"

printf '\n7. Subiendo los commits al repositorio del laboratorio.\n'
git push origin main

printf '\n8. Estado e historial finales.\n'
git status
git --no-pager log --oneline --graph --all --decorate -10
printf '\nProceso terminado. Comprueba los commits en GitHub.\n'
