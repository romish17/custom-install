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
  startTime: Date;
  endTime?: Date;
  logs: string[];
  exitCode?: number;
}

export interface InstallationProfile {
  id: string;
  name: string;
  platform: 'linux' | 'windows' | 'kali';
  scripts: string[];
  packages: string[];
  settings: Record<string, any>;
}

export interface SystemInfo {
  platform: string;
  arch: string;
  hostname: string;
  release: string;
  uptime: number;
}

export interface WebSocketMessage {
  type: 'log' | 'status' | 'error' | 'complete';
  executionId: string;
  data: any;
  timestamp: Date;
}
