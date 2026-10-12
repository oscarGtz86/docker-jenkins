# CLAUDE.md

Este archivo es la guía para Claude Code (claude.ai/code) al trabajar con el código de este
repositorio. El contexto general del workspace (plataforma de Claro, VPN, seguridad de PROD,
el flujo común de CI/CD) está en `../CLAUDE.md`.

## Resumen del proyecto

Este repositorio provee una instalación de Jenkins LTS corriendo en Docker con capacidades de
Docker-in-Docker (DinD). La arquitectura permite que los jobs de Jenkins ejecuten comandos de
Docker usando el daemon de Docker del host mediante el montaje del socket.

## Arquitectura

La instalación tiene tres componentes principales:

1. **Dockerfile**: extiende la imagen oficial `jenkins/jenkins:lts` e instala dentro del
   contenedor de Jenkins el CLI de Docker, Buildx y el plugin de Compose.
2. **docker-compose.yml**: orquesta el servicio de Jenkins con modo privilegiado, montaje del
   socket (`/var/run/docker.sock`) y volumen persistente.
3. **Estrategia de montaje del socket**: el daemon de Docker del host queda disponible para
   Jenkins al montar `/var/run/docker.sock`, de modo que Jenkins controla Docker sin correr
   Docker-in-Docker como un daemon aparte.

## Comandos comunes

### Construir y ejecutar
```bash
# Construir la imagen personalizada de Jenkins e iniciar el servicio
docker compose up -d

# Construir sin caché (cuando cambia el Dockerfile)
docker compose build --no-cache
docker compose up -d

# Ver logs
docker compose logs -f jenkins
```

### Acceso y configuración
```bash
# Obtener la contraseña inicial de administrador en el primer arranque
docker exec -it <nombre_del_contenedor> cat /var/jenkins_home/secrets/initialAdminPassword

# Entrar a una shell de Jenkins para depurar
docker exec -it <nombre_del_contenedor> bash
```

### Detener y limpiar
```bash
# Detener el servicio de Jenkins
docker compose down

# Borrar el volumen de datos de Jenkins (ADVERTENCIA: borra toda la configuración y los jobs)
docker volume rm docker-jenkins_jenkins_home
```

## Detalles clave de configuración

- **Puertos**: UI de Jenkins en `8080`, comunicación con agentes en `50000`
- **Modo privilegiado**: requerido para operaciones de Docker dentro de Jenkins
- **Usuario**: el contenedor corre como `root` para acceder al socket de Docker
- **Variables de entorno**:
  - `DOCKER_HOST=unix:///var/run/docker.sock`: apunta al daemon de Docker del host
  - `DOCKER_BUILDKIT=1`: habilita BuildKit para mejores builds

## Consideraciones de seguridad

El contenedor de Jenkins tiene acceso completo al daemon de Docker del host a través del
socket montado. Eso otorga control total sobre el host. Esta instalación solo debe usarse en
entornos de confianza, ya que un job de Jenkins comprometido podría manipular los contenedores
del host y potencialmente escapar del aislamiento.

## Acceso

Una vez iniciado, Jenkins está disponible en `http://localhost:8080`

## Papel en la plataforma de Claro

Este es el Jenkins que ejecuta el `Jenkinsfile` de claro-api, claro-dashboard, claro-poller,
claro-snmp-trap y meraki-webhooks. Los pipelines viven en esos repos, no aquí. Los cambios en
este repo solo deben tocar la imagen y la ejecución de Jenkins. Lo que los pipelines esperan
de este Jenkins:

- **Docker** con `buildx` (lo instala el `Dockerfile`), más `python3` (lo usan pasos de los
  pipelines).
- **Instalaciones de la herramienta NodeJS** con estos nombres exactos: `NodeJS_20_18_0`
  (claro-api, meraki-webhooks) y `NodeJS_18_20_8` (claro-dashboard). Deben coincidir con el
  `.nvmrc` de cada repo.
- **IDs de credenciales**: `dockerhub-creds` (publicar en `developerfocus/*`), `github-user`
  (hace push a `main` del commit de versión `[ci skip]`), `claro-backend-ssh` /
  `claro-dashboard-ssh` (despliegues por SSH como `FocusIT`), y los IDs de texto secreto que se
  usan para generar los `.env` (`MONGO_URL`, `MONGO_DB_NAME`, `SECRET`, `ORA_*`, `OPCHARTS_*`,
  `SM_*`). Renombrar cualquiera rompe todos los pipelines que lo usan.
- Alcance de red a los hosts de Claro (`10.20.10.x`) para los despliegues.

## Seguridad

`docker volume rm`, restaurar un respaldo y `docker compose down -v` destruyen los jobs y las
credenciales de Jenkins. Pregunta al usuario antes de ejecutar cualquiera de ellos y haz antes
un respaldo (ver README). `jenkins-backups/*.tar.gz` contiene credenciales: nunca subas ni
compartas esos archivos (`.gitignore` cubre la carpeta).

## Idioma

El español es canónico (ver "Idioma" en `../CLAUDE.md`): comentarios del `Dockerfile` y de
compose, y la documentación nueva o reescrita, van en español.
