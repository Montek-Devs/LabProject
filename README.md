# LabProject

Entorno de desarrollo/prototipado **enterprise** para **Frappe Framework + React** en **Windows Server 2022**, con arquitectura **Linux-first** (WSL2 + Docker) y frontend desacoplado.

Repositorio: [Montek-Devs/LabProject](https://github.com/Montek-Devs/LabProject.git)

---

## Arquitectura (decisión técnica)

| Capa | Tecnología | Ubicación | Motivo |
|------|------------|-----------|--------|
| **Datos** | MariaDB 10.6 + Redis 7 | Docker (persistente) | Estable, backups, mismo stack que producción |
| **Backend** | Frappe v15 + Bench | **WSL2 Ubuntu** | Frappe no soporta Windows nativo; hot-reload Python/JS |
| **Frontend** | React 18 + Vite + Axios | **Windows** | Mejor DX hot-reload; proxy dev a Frappe |
| **Apps** | `lab_core` (+ futuros módulos) | `apps/` → symlink en bench | Escalable, un app por dominio |
| **Orquestación** | Docker Compose + scripts PS1/bash | `docker/`, `scripts/` | Persistencia tras reinicio (`restart: unless-stopped`) |

**Por qué no Frappe 100% en Docker en dev:** Bench en WSL con volúmenes montados desde `C:\LabProject` permite `bench migrate`, `bench watch` y desarrollo de DocTypes con menor fricción. Docker corre **solo la capa de datos** por defecto; el perfil `full` levanta Frappe en contenedor para paridad CI/producción.

```
┌─────────────────────────────────────────────────────────────┐
│  Windows Server 2022                                        │
│  ┌──────────────┐    proxy /api    ┌──────────────────────┐ │
│  │ React (Vite) │ ───────────────► │ Frappe (bench / WSL) │ │
│  │ :5173        │                  │ :8000 / :9000        │ │
│  └──────────────┘                  └──────────┬───────────┘ │
│                                               │             │
│  ┌────────────────────────────────────────────▼───────────┐ │
│  │ Docker: MariaDB :3306, Redis :6379 / :6380             │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## Requisitos mínimos

- Windows Server 2022
- 8 GB RAM (16 GB recomendado)
- Virtualización habilitada (Hyper-V / WSL2)
- 50 GB disco libre
- Acceso a Internet (winget, Docker, bench init)

---

## Instalación automática (primera vez)

Abre **PowerShell como Administrador**:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
cd C:\LabProject
.\scripts\setup-all.ps1
```

Esto ejecuta:

1. `01-setup-windows.ps1` — WSL2, Git, Node LTS, Docker Desktop, Yarn
2. `03-setup-docker.ps1` — MariaDB + Redis
3. `02-setup-wsl.sh` — Bench, site `lab.localhost`, app `lab_core`
4. `04-init-frontend.ps1` — dependencias React
5. `05-git-init.ps1` — commit inicial y remote GitHub

**Reinicio:** Tras habilitar WSL/Hyper-V puede ser necesario reiniciar. Complete el usuario de Ubuntu en el primer arranque.

**GitHub push:**

```powershell
cd C:\LabProject
git push -u origin main
```

Use `gh auth login` o Personal Access Token si el push falla.

---

## Inicio diario del entorno

```powershell
cd C:\LabProject
.\scripts\start-dev.ps1
```

O por componentes:

```powershell
cd C:\LabProject\docker && docker compose up -d    # solo datos
wsl -d Ubuntu -e bash -lc "cd /mnt/c/LabProject/backend/frappe-bench && bench start"
cd C:\LabProject\frontend && npm run dev
```

**Detener:**

```powershell
.\scripts\stop-dev.ps1
```

**Validar:**

```powershell
.\scripts\validate.ps1
```

---

## URLs y puertos

| Servicio | URL / Puerto |
|----------|----------------|
| Frappe Desk | http://127.0.0.1:8000 |
| Frappe Socketio | http://127.0.0.1:9000 |
| React (Vite) | http://127.0.0.1:5173 |
| API ping (guest) | http://127.0.0.1:8000/api/method/lab_core.api.ping |
| MariaDB | localhost:3307 (root/admin) — puerto 3307 evita conflicto con otros stacks |
| Redis cache | localhost:6379 |
| Redis queue | localhost:6380 |

**Credenciales por defecto (cambiar en producción):**

- Frappe: `Administrator` / `admin`
- MariaDB root: `admin`

---

## Estructura del proyecto

```
C:\LabProject\
├── apps/
│   └── lab_core/          # App Frappe (API + DocTypes)
├── backend/
│   └── frappe-bench/      # Generado por bench init (gitignored)
├── frontend/              # React + Vite
├── docker/
│   ├── docker-compose.yml
│   ├── config/
│   └── backups/
├── docs/
├── scripts/               # Setup, start, stop, validate
├── package.json           # npm run dev (orquestación)
└── README.md
```

---

## Crear nuevos módulos

```bash
# En WSL
cd /mnt/c/LabProject/backend/frappe-bench
bench new-app lab_inventory   # ejemplo
# Mover o enlazar a C:\LabProject\apps\
ln -sf /mnt/c/LabProject/apps/lab_inventory apps/lab_inventory
bench --site lab.localhost install-app lab_inventory
bench --site lab.localhost migrate
```

Convención: un directorio por app en `C:\LabProject\apps\<nombre_app>`.

---

## API `lab_core` (ejemplo CRUD)

| Método Frappe | Auth | Descripción |
|---------------|------|-------------|
| `lab_core.api.ping` | Guest | Health check |
| `lab_core.api.list_lab_items` | User | Listar |
| `lab_core.api.create_lab_item` | User | Crear |
| `lab_core.api.update_lab_item` | User | Actualizar |
| `lab_core.api.delete_lab_item` | User | Eliminar |

DocType: **Lab Sample Item** (`LAB-#####`)

El frontend en `/items` consume estas APIs vía proxy Vite (`/api` → Frappe).

**Auth en dev:** Inicie sesión en Desk (`http://127.0.0.1:8000`) para que las cookies de sesión permitan métodos autenticados desde React (`withCredentials: true`).

---

## Despliegue futuro (producción)

1. **Staging/Prod:** Use `docker compose --profile full` o imágenes oficiales [frappe_docker](https://github.com/frappe/frappe_docker).
2. **Secrets:** Variables en `.env` (no commitear); use Azure Key Vault / HashiCorp Vault.
3. **Frontend:** `npm run build` → servir estáticos en CDN o Nginx; API en subdominio `api.`.
4. **HTTPS:** Traefik / Nginx reverse proxy + Let's Encrypt.
5. **Backups:** `docker compose --profile backup run backup` (ver `docker-compose.yml`).
6. **CI/CD:** GitHub Actions — lint, `bench run-tests`, build Docker, deploy.

---

## Troubleshooting

Ver [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

| Problema | Solución rápida |
|----------|-----------------|
| Docker no inicia | Abrir Docker Desktop; `wsl --update` |
| bench no encontrado | Re-ejecutar `02-setup-wsl.sh` |
| API 403 en React | Login en Desk; verificar CORS en site config |
| Puerto 3307 ocupado | Cambiar puerto en `docker-compose.yml` y `--db-port` en `02-setup-wsl.sh` |
| Permisos WSL en `/mnt/c` | Preferir bench en path WSL nativo si hay lentitud |

---

## Mejores prácticas empresariales

- Nunca instalar Frappe en Windows nativo; siempre WSL2 o Linux.
- Mantener `apps/` como fuente de verdad; bench es runtime.
- Versionar solo código; excluir `frappe-bench/sites` y `node_modules` (`.gitignore`).
- Un repo; múltiples apps Frappe bajo `apps/`.
- Ramas: `main` (estable), `develop`, `feature/*`.
- Rotar contraseñas por defecto antes de cualquier exposición de red.

---

## Licencia

MIT — Montek Devs / LabProject
