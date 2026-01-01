import { ScriptExecution } from '../types';
import { v4 as uuidv4 } from 'uuid';
import { spawn, ChildProcess } from 'child_process';
import { getScriptPath } from './scriptService';
import { broadcastToClients } from '../websocket';
import * as os from 'os';

const executions: Map<string, ScriptExecution> = new Map();
const runningProcesses: Map<string, ChildProcess> = new Map();

export async function executeScript(
  scriptId: string,
  options: Record<string, any> = {}
): Promise<ScriptExecution> {
  const executionId = uuidv4();
  const scriptPath = getScriptPath(scriptId);

  if (!scriptPath) {
    throw new Error(`Script not found: ${scriptId}`);
  }

  const execution: ScriptExecution = {
    id: executionId,
    scriptId,
    status: 'pending',
    startTime: new Date(),
    logs: []
  };

  executions.set(executionId, execution);

  // Start execution asynchronously
  setImmediate(() => runScript(execution, scriptPath, options));

  return execution;
}

async function runScript(
  execution: ScriptExecution,
  scriptPath: string,
  options: Record<string, any>
): Promise<void> {
  execution.status = 'running';
  broadcastExecutionUpdate(execution);

  const isWindows = os.platform() === 'win32';
  const isPowerShell = scriptPath.endsWith('.ps1');
  const isBash = scriptPath.endsWith('.sh');

  let command: string;
  let args: string[];

  if (isWindows && isPowerShell) {
    command = 'powershell.exe';
    args = ['-ExecutionPolicy', 'Bypass', '-File', scriptPath];
  } else if (isBash) {
    command = 'bash';
    args = [scriptPath];
  } else {
    execution.status = 'failed';
    execution.endTime = new Date();
    execution.logs.push('ERROR: Unsupported script type');
    broadcastExecutionUpdate(execution);
    return;
  }

  // Add options as arguments
  if (options.args && Array.isArray(options.args)) {
    args.push(...options.args);
  }

  const process = spawn(command, args, {
    shell: true,
    env: { ...process.env, ...options.env }
  });

  runningProcesses.set(execution.id, process);

  process.stdout?.on('data', (data: Buffer) => {
    const log = data.toString();
    execution.logs.push(log);
    broadcastLog(execution.id, log);
  });

  process.stderr?.on('data', (data: Buffer) => {
    const log = `ERROR: ${data.toString()}`;
    execution.logs.push(log);
    broadcastLog(execution.id, log);
  });

  process.on('close', (code: number | null) => {
    execution.status = code === 0 ? 'completed' : 'failed';
    execution.exitCode = code ?? undefined;
    execution.endTime = new Date();

    runningProcesses.delete(execution.id);
    broadcastExecutionUpdate(execution);

    console.log(`Script execution ${execution.id} finished with code ${code}`);
  });

  process.on('error', (error: Error) => {
    execution.status = 'failed';
    execution.endTime = new Date();
    execution.logs.push(`FATAL ERROR: ${error.message}`);

    runningProcesses.delete(execution.id);
    broadcastExecutionUpdate(execution);

    console.error(`Script execution ${execution.id} error:`, error);
  });
}

export async function getExecution(id: string): Promise<ScriptExecution | undefined> {
  return executions.get(id);
}

export async function getAllExecutions(): Promise<ScriptExecution[]> {
  return Array.from(executions.values()).sort(
    (a, b) => b.startTime.getTime() - a.startTime.getTime()
  );
}

function broadcastExecutionUpdate(execution: ScriptExecution): void {
  broadcastToClients({
    type: 'execution_update',
    data: execution,
    timestamp: new Date()
  });
}

function broadcastLog(executionId: string, log: string): void {
  broadcastToClients({
    type: 'log',
    executionId,
    data: { log },
    timestamp: new Date()
  });
}
