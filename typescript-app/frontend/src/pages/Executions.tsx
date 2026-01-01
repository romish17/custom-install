import { useEffect, useState } from 'react';
import { api } from '../api/client';
import { ScriptExecution } from '../types';
import { useExecutionStore } from '../store/executionStore';
import { CheckCircle, XCircle, Clock, Play } from 'lucide-react';
import clsx from 'clsx';

export default function Executions() {
  const [selectedExecution, setSelectedExecution] = useState<string | null>(null);
  const { getAllExecutions } = useExecutionStore();
  const executions = getAllExecutions();

  useEffect(() => {
    loadExecutions();
  }, []);

  const loadExecutions = async () => {
    try {
      const { data } = await api.getExecutions();
      data.forEach((execution: ScriptExecution) => {
        useExecutionStore.getState().updateExecution(execution);
      });
    } catch (error) {
      console.error('Failed to load executions:', error);
    }
  };

  const selectedExecutionData = selectedExecution
    ? executions.find((e) => e.id === selectedExecution)
    : null;

  return (
    <div className="p-8 h-full flex flex-col">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-white mb-2">Executions</h1>
        <p className="text-gray-400">Script execution history and logs</p>
      </div>

      <div className="flex-1 grid grid-cols-1 lg:grid-cols-3 gap-6 min-h-0">
        {/* Execution list */}
        <div className="lg:col-span-1 bg-gray-900 rounded-xl border border-gray-800 overflow-hidden flex flex-col">
          <div className="p-4 border-b border-gray-800">
            <h2 className="font-semibold text-white">Recent Executions</h2>
          </div>
          <div className="flex-1 overflow-y-auto">
            {executions.length === 0 ? (
              <div className="p-4 text-center text-gray-400">
                No executions yet
              </div>
            ) : (
              executions.map((execution) => (
                <button
                  key={execution.id}
                  onClick={() => setSelectedExecution(execution.id)}
                  className={clsx(
                    'w-full p-4 border-b border-gray-800 text-left hover:bg-gray-800/50 transition-colors',
                    selectedExecution === execution.id && 'bg-gray-800'
                  )}
                >
                  <div className="flex items-center justify-between mb-2">
                    <span className="font-medium text-white text-sm truncate">
                      {execution.scriptId}
                    </span>
                    <StatusIcon status={execution.status} />
                  </div>
                  <div className="text-xs text-gray-400">
                    {new Date(execution.startTime).toLocaleString()}
                  </div>
                </button>
              ))
            )}
          </div>
        </div>

        {/* Execution details */}
        <div className="lg:col-span-2 bg-gray-900 rounded-xl border border-gray-800 overflow-hidden flex flex-col">
          {selectedExecutionData ? (
            <>
              <div className="p-4 border-b border-gray-800">
                <div className="flex items-center justify-between">
                  <h2 className="font-semibold text-white">
                    Execution Details
                  </h2>
                  <StatusBadge status={selectedExecutionData.status} />
                </div>
                <div className="mt-2 text-sm text-gray-400">
                  ID: {selectedExecutionData.id}
                </div>
              </div>
              <div className="flex-1 overflow-y-auto p-4">
                <div className="bg-black rounded-lg p-4 font-mono text-sm">
                  {selectedExecutionData.logs.length === 0 ? (
                    <div className="text-gray-500">No logs yet...</div>
                  ) : (
                    selectedExecutionData.logs.map((log, index) => (
                      <div key={index} className="text-gray-300">
                        {log}
                      </div>
                    ))
                  )}
                </div>
              </div>
            </>
          ) : (
            <div className="flex items-center justify-center h-full text-gray-400">
              Select an execution to view details
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

function StatusIcon({ status }: { status: string }) {
  switch (status) {
    case 'completed':
      return <CheckCircle className="w-4 h-4 text-green-400" />;
    case 'failed':
      return <XCircle className="w-4 h-4 text-red-400" />;
    case 'running':
      return <Play className="w-4 h-4 text-cyan-400 animate-pulse" />;
    default:
      return <Clock className="w-4 h-4 text-gray-400" />;
  }
}

function StatusBadge({ status }: { status: string }) {
  const classes = clsx(
    'px-3 py-1 rounded-full text-xs font-medium',
    status === 'completed' && 'bg-green-500/10 text-green-400',
    status === 'failed' && 'bg-red-500/10 text-red-400',
    status === 'running' && 'bg-cyan-500/10 text-cyan-400',
    status === 'pending' && 'bg-gray-500/10 text-gray-400'
  );

  return <span className={classes}>{status}</span>;
}
