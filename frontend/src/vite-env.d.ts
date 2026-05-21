/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_FRAPPE_HOST: string;
  readonly VITE_FRAPPE_SITE: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
