# Guía de módulos — LabProject

## Convenciones de nombres

- App Frappe: `lab_<dominio>` (snake_case)
- DocTypes: Pascal Case con espacio (`Lab Sample Item`)
- API: `lab_<dominio>.api.<función>` whitelisted

## Crear módulo nuevo

### 1. Crear app

```bash
cd /mnt/c/LabProject/backend/frappe-bench
bench new-app lab_inventory
```

O copiar estructura desde `apps/lab_core`.

### 2. Ubicar en monorepo

```bash
mv apps/lab_inventory /mnt/c/LabProject/apps/
ln -sf /mnt/c/LabProject/apps/lab_inventory apps/lab_inventory
```

### 3. Instalar en site

```bash
bench --site lab.localhost install-app lab_inventory
bench --site lab.localhost migrate
```

### 4. Exponer API

En `lab_inventory/api.py`:

```python
@frappe.whitelist()
def list_items():
    return frappe.get_all("Inventory Item", fields=["name", "item_code"])
```

### 5. Consumir desde React

```typescript
await callMethod("lab_inventory.api.list_items");
```

### 6. Tests

```bash
bench --site lab.localhost run-tests --app lab_inventory
```

## Checklist antes de merge

- [ ] DocType JSON exportado
- [ ] Permisos por rol definidos
- [ ] APIs documentadas en README del app
- [ ] Tests pasan
- [ ] Sin secrets en código
