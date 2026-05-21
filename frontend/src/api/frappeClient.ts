import axios, { AxiosInstance } from "axios";

const site = import.meta.env.VITE_FRAPPE_SITE || "lab.localhost";

/** Axios client for Frappe REST/RPC via Vite proxy */
export const frappeApi: AxiosInstance = axios.create({
  baseURL: "/api",
  withCredentials: true,
  headers: {
    "Content-Type": "application/json",
    "X-Frappe-Site-Name": site,
  },
});

export async function callMethod<T>(
  method: string,
  args?: Record<string, unknown>
): Promise<T> {
  const { data } = await frappeApi.post<{ message: T }>(
    `/method/${method}`,
    args ?? {}
  );
  return data.message;
}

export interface LabItem {
  name: string;
  item_name: string;
  description?: string;
  status: string;
  modified?: string;
}

export const labItemsApi = {
  ping: () => callMethod<{ status: string; message: string }>("lab_core.api.ping"),
  list: () => callMethod<LabItem[]>("lab_core.api.list_lab_items"),
  create: (payload: { item_name: string; description?: string; status?: string }) =>
    callMethod<LabItem>("lab_core.api.create_lab_item", payload),
  update: (payload: {
    name: string;
    item_name?: string;
    description?: string;
    status?: string;
  }) => callMethod<LabItem>("lab_core.api.update_lab_item", payload),
  delete: (name: string) =>
    callMethod<{ deleted: string }>("lab_core.api.delete_lab_item", { name }),
};
