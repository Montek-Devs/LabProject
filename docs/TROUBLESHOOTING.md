# Troubleshooting — LabProject

## Validación inicial

```powershell
cd C:\LabProject
.\scripts\validate.ps1
```

## WSL2

### "WSL 2 requires an update"

```powershell
wsl --update
wsl --set-default-version 2
```

### systemd no activo

En Ubuntu:

```bash
sudo tee /etc/wsl.conf <<EOF
[boot]
systemd=true
EOF
```

Luego en PowerShell: `wsl --shutdown`

### Docker no visible en WSL

Docker Desktop → Settings → Resources → WSL Integration → habilitar **Ubuntu-24.04**.

## Docker

### Docker Desktop no arranca en Server

- Confirmar rol/contenedor Hyper-V
- Instalar actualización KB para WSL2
- Reiniciar servicio: `Restart-Service docker` (si Docker Engine sin Desktop)

### Puerto en uso

Editar `docker/docker-compose.yml` y `bench` site config con nuevos puertos.

## Frappe / Bench

### `bench init` falla

```bash
sudo apt install python3-dev build-essential
pip3 install frappe-bench --upgrade
```

### Site no conecta a MariaDB

Verificar Docker: `docker compose ps` — `db` healthy.

```bash
bench --site lab.localhost set-config db_host 127.0.0.1
bench --site lab.localhost set-config db_port 3306
```

### lab_core no instalada

```bash
cd /mnt/c/LabProject/backend/frappe-bench
bench --site lab.localhost install-app lab_core
bench --site lab.localhost migrate
```

## React

### API 403 / Not permitted

1. Abrir http://127.0.0.1:8000 e iniciar sesión como Administrator
2. Verificar `developer_mode` y CORS en site config
3. Para guest-only endpoints usar métodos con `allow_guest=True` (ej. `ping`)

### Proxy no funciona

Comprobar `frontend/.env`:

```
VITE_FRAPPE_HOST=http://127.0.0.1:8000
```

Reiniciar `npm run dev`.

## Git / GitHub

### push rejected

```powershell
gh auth login
git remote -v
git push -u origin main
```

### Credenciales HTTPS

Usar PAT de GitHub con scope `repo`.

## Logs

| Componente | Ubicación |
|------------|-----------|
| Frappe | `backend/frappe-bench/logs/` |
| Docker | `docker logs labproject-mariadb` |
| Vite | Terminal `npm run dev` |
