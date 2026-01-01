import { create } from 'zustand';
import { ScriptExecution } from '../types';

interface ExecutionStore {
  executions: Map<string, ScriptExecution>;
  addExecution: (execution: ScriptExecution) => void;
  updateExecution: (execution: ScriptExecution) => void;
  addLog: (executionId: string, log: string) => void;
  getExecution: (id: string) => ScriptExecution | undefined;
  getAllExecutions: () => ScriptExecution[];
}

export const useExecutionStore = create<ExecutionStore>((set, get) => ({
  executions: new Map(),

  addExecution: (execution) => {
    set((state) => {
      const newExecutions = new Map(state.executions);
      newExecutions.set(execution.id, execution);
      return { executions: newExecutions };
    });
  },

  updateExecution: (execution) => {
    set((state) => {
      const newExecutions = new Map(state.executions);
      newExecutions.set(execution.id, execution);
      return { executions: newExecutions };
    });
  },

  addLog: (executionId, log) => {
    set((state) => {
      const execution = state.executions.get(executionId);
      if (!execution) return state;

      const newExecutions = new Map(state.executions);
      newExecutions.set(executionId, {
        ...execution,
        logs: [...execution.logs, log],
      });
      return { executions: newExecutions };
    });
  },

  getExecution: (id) => {
    return get().executions.get(id);
  },

  getAllExecutions: () => {
    return Array.from(get().executions.values()).sort(
      (a, b) => new Date(b.startTime).getTime() - new Date(a.startTime).getTime()
    );
  },
}));
