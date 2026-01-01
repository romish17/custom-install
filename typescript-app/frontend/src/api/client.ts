import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3001';

export const apiClient = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const api = {
  // System
  getSystemInfo: () => apiClient.get('/api/system/info'),

  // Scripts
  getScripts: (platform?: string) =>
    apiClient.get('/api/scripts', { params: { platform } }),
  getScript: (id: string) => apiClient.get(`/api/scripts/${id}`),

  // Executions
  executeScript: (scriptId: string, options?: Record<string, any>) =>
    apiClient.post('/api/execute', { scriptId, options }),
  getExecutions: () => apiClient.get('/api/executions'),
  getExecution: (id: string) => apiClient.get(`/api/executions/${id}`),
};
