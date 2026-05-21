# lab_core

Core Frappe application for LabProject.

## API endpoints (whitelisted)

| Method | Auth | Description |
|--------|------|-------------|
| `lab_core.api.ping` | Guest | Health check |
| `lab_core.api.list_lab_items` | User | List items |
| `lab_core.api.create_lab_item` | User | Create item |
| `lab_core.api.update_lab_item` | User | Update item |
| `lab_core.api.delete_lab_item` | User | Delete item |

Install on site:

```bash
bench --site lab.localhost install-app lab_core
bench --site lab.localhost migrate
```
