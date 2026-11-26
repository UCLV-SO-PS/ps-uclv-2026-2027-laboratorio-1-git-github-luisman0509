# Laboratorio 1: Git y GitHub
## Nota:5
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
