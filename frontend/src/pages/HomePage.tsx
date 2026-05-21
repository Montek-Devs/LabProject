import { useEffect, useState } from "react";
import { labItemsApi } from "../api/frappeClient";

export default function HomePage() {
  const [status, setStatus] = useState<string>("checking...");
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    labItemsApi
      .ping()
      .then((res) => setStatus(res.message))
      .catch((e) => setError(e.message || "API unreachable"));
  }, []);

  return (
    <div className="card">
      <h2>LabProject Frontend</h2>
      <p>React + Vite desacoplado consumiendo API Frappe vía proxy.</p>
      <h3>API Health</h3>
      {error ? (
        <p className="error">
          {error} — Asegúrate de que Frappe esté en marcha (bench start) y hayas
          iniciado sesión en <a href="http://127.0.0.1:8000">Desk</a>.
        </p>
      ) : (
        <p className="success">{status}</p>
      )}
      <ul>
        <li>Frappe Desk: http://127.0.0.1:8000</li>
        <li>React Dev: http://127.0.0.1:5173</li>
        <li>Site: lab.localhost</li>
      </ul>
    </div>
  );
}
