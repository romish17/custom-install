import { useEffect, useState } from 'react';
import { api } from '../api/client';
import { Script } from '../types';
import { Play, Terminal, Layers } from 'lucide-react';
import { useExecutionStore } from '../store/executionStore';
import clsx from 'clsx';

export default function Scripts() {
  const [scripts, setScripts] = useState<Script[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedPlatform, setSelectedPlatform] = useState<string>('all');
  const { addExecution } = useExecutionStore();

  useEffect(() => {
    loadScripts();
  }, [selectedPlatform]);

  const loadScripts = async () => {
    try {
      const platform = selectedPlatform === 'all' ? undefined : selectedPlatform;
      const { data } = await api.getScripts(platform);
      setScripts(data);
    } catch (error) {
      console.error('Failed to load scripts:', error);
    } finally {
      setLoading(false);
    }
  };

  const executeScript = async (scriptId: string) => {
    try {
      const { data } = await api.executeScript(scriptId);
      addExecution(data);
      alert(`Script execution started: ${data.id}`);
    } catch (error) {
      console.error('Failed to execute script:', error);
      alert('Failed to execute script');
    }
  };

  const platforms = [
    { value: 'all', label: 'All Platforms' },
    { value: 'linux', label: 'Linux' },
    { value: 'windows', label: 'Windows' },
    { value: 'kali', label: 'Kali Linux' },
  ];

  if (loading) {
    return (
      <div className="flex items-center justify-center h-full">
        <div className="text-gray-400">Loading scripts...</div>
      </div>
    );
  }

  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-white mb-2">Scripts</h1>
        <p className="text-gray-400">Available installation scripts</p>
      </div>

      {/* Platform filter */}
      <div className="flex space-x-2 mb-6">
        {platforms.map((platform) => (
          <button
            key={platform.value}
            onClick={() => setSelectedPlatform(platform.value)}
            className={clsx(
              'px-4 py-2 rounded-lg font-medium transition-colors',
              selectedPlatform === platform.value
                ? 'bg-cyan-500 text-white'
                : 'bg-gray-800 text-gray-400 hover:bg-gray-700'
            )}
          >
            {platform.label}
          </button>
        ))}
      </div>

      {/* Scripts grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {scripts.map((script) => (
          <div
            key={script.id}
            className="bg-gray-900 rounded-xl p-6 border border-gray-800 hover:border-cyan-500/50 transition-colors"
          >
            <div className="flex items-start justify-between mb-4">
              <div className="w-12 h-12 bg-gradient-to-br from-cyan-500 to-blue-600 rounded-lg flex items-center justify-center">
                <Terminal className="w-6 h-6 text-white" />
              </div>
              <span className={clsx(
                'px-3 py-1 rounded-full text-xs font-medium',
                script.platform === 'windows' && 'bg-blue-500/10 text-blue-400',
                script.platform === 'linux' && 'bg-green-500/10 text-green-400',
                script.platform === 'kali' && 'bg-purple-500/10 text-purple-400'
              )}>
                {script.platform}
              </span>
            </div>

            <h3 className="text-lg font-bold text-white mb-2">{script.name}</h3>
            <p className="text-sm text-gray-400 mb-4 line-clamp-3">{script.description}</p>

            <div className="flex items-center text-xs text-gray-500 mb-4">
              <Layers className="w-4 h-4 mr-1" />
              {script.category}
            </div>

            <button
              onClick={() => executeScript(script.id)}
              disabled={!script.enabled}
              className={clsx(
                'w-full flex items-center justify-center space-x-2 px-4 py-2 rounded-lg font-medium transition-colors',
                script.enabled
                  ? 'bg-cyan-500 hover:bg-cyan-600 text-white'
                  : 'bg-gray-800 text-gray-500 cursor-not-allowed'
              )}
            >
              <Play className="w-4 h-4" />
              <span>{script.enabled ? 'Execute' : 'Disabled'}</span>
            </button>
          </div>
        ))}
      </div>

      {scripts.length === 0 && (
        <div className="text-center text-gray-400 py-12">
          No scripts found for the selected platform
        </div>
      )}
    </div>
  );
}
