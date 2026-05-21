import { Routes, Route, Link } from "react-router-dom";
import HomePage from "./pages/HomePage";
import ItemsPage from "./pages/ItemsPage";

export default function App() {
  return (
    <div className="app">
      <header className="header">
        <h1>LabProject</h1>
        <nav>
          <Link to="/">Home</Link>
          <Link to="/items">Lab Items (CRUD)</Link>
        </nav>
      </header>
      <main className="main">
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/items" element={<ItemsPage />} />
        </Routes>
      </main>
    </div>
  );
}
