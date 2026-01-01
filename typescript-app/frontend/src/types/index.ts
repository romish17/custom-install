export interface Script {
  id: string;
  name: string;
  description: string;
  platform: 'linux' | 'windows' | 'kali';
  category: string;
  path: string;
  enabled: boolean;
}

export interface ScriptExecution {
  id: string;
  scriptId: string;
  status: 'pending' | 'running' | 'completed' | 'failed';
  startTime: string;
  endTime?: string;
  logs: string[];
  exitCode?: number;
}

export interface SystemInfo {
  platform: string;
  arch: string;
  hostname: string;
  release: string;
  uptime: number;
}

export interface WebSocketMessage {
  type: 'log' | 'status' | 'error' | 'complete' | 'execution_update' | 'connected' | 'pong';
  executionId?: string;
  data?: any;
  timestamp: string;
  clientId?: string;
}
