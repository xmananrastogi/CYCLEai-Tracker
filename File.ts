//
//  File.ts
//  CYCLEai-Tracker
//
//  Created by Manan Rastogi on 14/09/25.
//

import { QueryClient, QueryFunction } from "@tanstack/react-query";
import { authClient } from "./auth"; // Assuming authClient is in a separate file

async function throwIfResNotOk(res: Response) {
  if (!res.ok) {
    const text = (await res.text()) || res.statusText;
    throw new Error(`${res.status}: ${text}`);
  }
}

export async function apiRequest(
  method: string,
  url: string,
  data?: unknown | undefined,
): Promise<Response> {
  const authHeaders = authClient.getAuthHeaders();
  const contentTypeHeaders = data ? { "Content-Type": "application/json" } : {};
  
  const res = await fetch(url, {
    method,
    headers: {
      ...authHeaders,
      ...contentTypeHeaders,
    },
    body: data ? JSON.stringify(data) : undefined,
    credentials: "include",
  });

  throwIfResNotOk(res);
  return res;
}
