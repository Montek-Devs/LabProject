import { FormEvent, useCallback, useEffect, useState } from "react";
import { LabItem, labItemsApi } from "../api/frappeClient";

export default function ItemsPage() {
  const [items, setItems] = useState<LabItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [itemName, setItemName] = useState("");
  const [description, setDescription] = useState("");

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await labItemsApi.list();
      setItems(data);
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : "Failed to load items";
      setError(
        `${msg}. Login at http://127.0.0.1:8000 (Administrator/admin) then refresh.`
      );
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  async function handleCreate(e: FormEvent) {
    e.preventDefault();
    if (!itemName.trim()) return;
    await labItemsApi.create({
      item_name: itemName,
      description,
      status: "Draft",
    });
    setItemName("");
    setDescription("");
    load();
  }

  async function handleDelete(name: string) {
    if (!confirm(`Delete ${name}?`)) return;
    await labItemsApi.delete(name);
    load();
  }

  async function toggleStatus(item: LabItem) {
    const next = item.status === "Active" ? "Archived" : "Active";
    await labItemsApi.update({ name: item.name, status: next });
    load();
  }

  return (
    <div>
      <div className="card">
        <h2>Lab Sample Items (CRUD)</h2>
        <form onSubmit={handleCreate}>
          <label>Item Name</label>
          <input
            value={itemName}
            onChange={(e) => setItemName(e.target.value)}
            placeholder="New item name"
          />
          <label>Description</label>
          <textarea
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            rows={2}
          />
          <button type="submit" className="primary">
            Create
          </button>
        </form>
      </div>

      <div className="card">
        {loading && <p>Loading...</p>}
        {error && <p className="error">{error}</p>}
        {!loading && !error && (
          <table>
            <thead>
              <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {items.map((item) => (
                <tr key={item.name}>
                  <td>{item.name}</td>
                  <td>{item.item_name}</td>
                  <td>{item.status}</td>
                  <td>
                    <button onClick={() => toggleStatus(item)}>Toggle status</button>{" "}
                    <button onClick={() => handleDelete(item.name)}>Delete</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
        {items.length === 0 && !loading && !error && <p>No items yet.</p>}
      </div>
    </div>
  );
}
