import { defineConfig, loadEnv } from "vite";
import react from "@vitejs/plugin-react";


export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), "");
  const frappeHost = env.VITE_FRAPPE_HOST || "http://127.0.0.1:8000";

  return {
    plugins: [react()],
    server: {
      port: 5173,
      strictPort: true,
      proxy: {
        "/api": {
          target: frappeHost,
          changeOrigin: true,
          secure: false,
        },
        "/assets": {
          target: frappeHost,
          changeOrigin: true,
        },
      },
    },
  };
});
