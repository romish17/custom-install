import { useEffect, useState } from 'react';
import { api } from '../api/client';
import { SystemInfo } from '../types';
import { Server, Cpu, HardDrive, Clock } from 'lucide-react';

export default function Dashboard() {
  const [systemInfo, setSystemInfo] = useState<SystemInfo | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadSystemInfo();
  }, []);

  const loadSystemInfo = async () => {
    try {
      const { data } = await api.getSystemInfo();
      setSystemInfo(data);
    } catch (error) {
      console.error('Failed to load system info:', error);
    } finally {
      setLoading(false);
    }
  };

  const formatUptime = (seconds: number) => {
    const days = Math.floor(seconds / 86400);
    const hours = Math.floor((seconds % 86400) / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    return `${days}d ${hours}h ${minutes}m`;
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-full">
        <div className="text-gray-400">Loading...</div>
      </div>
    );
  }

  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-white mb-2">Dashboard</h1>
        <p className="text-gray-400">System information and overview</p>
      </div>

      {systemInfo && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <StatCard
            icon={Server}
            label="Platform"
            value={systemInfo.platform}
            color="cyan"
          />
          <StatCard
            icon={Cpu}
            label="Architecture"
            value={systemInfo.arch}
            color="blue"
          />
          <StatCard
            icon={HardDrive}
            label="Hostname"
            value={systemInfo.hostname}
            color="purple"
          />
          <StatCard
            icon={Clock}
            label="Uptime"
            value={formatUptime(systemInfo.uptime)}
            color="green"
          />
        </div>
      )}

      <div className="bg-gray-900 rounded-xl p-6 border border-gray-800">
        <h2 className="text-xl font-bold text-white mb-4">Welcome</h2>
        <p className="text-gray-400 mb-4">
          This is the Custom Installation Manager - a web interface for managing and executing
          your installation scripts across different platforms.
        </p>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <FeatureCard
            title="Automated Scripts"
            description="Execute pre-configured installation scripts for Linux, Windows, and Kali"
          />
          <FeatureCard
            title="Real-time Logs"
            description="Monitor script execution with live log streaming via WebSocket"
          />
          <FeatureCard
            title="Cross-platform"
            description="Manage installations across different operating systems from one interface"
          />
        </div>
      </div>
    </div>
  );
}

interface StatCardProps {
  icon: React.ElementType;
  label: string;
  value: string;
  color: 'cyan' | 'blue' | 'purple' | 'green';
}

function StatCard({ icon: Icon, label, value, color }: StatCardProps) {
  const colorClasses = {
    cyan: 'from-cyan-500 to-blue-600',
    blue: 'from-blue-500 to-indigo-600',
    purple: 'from-purple-500 to-pink-600',
    green: 'from-green-500 to-emerald-600',
  };

  return (
    <div className="bg-gray-900 rounded-xl p-6 border border-gray-800">
      <div className="flex items-center justify-between mb-4">
        <div className={`w-12 h-12 bg-gradient-to-br ${colorClasses[color]} rounded-lg flex items-center justify-center`}>
          <Icon className="w-6 h-6 text-white" />
        </div>
      </div>
      <div className="text-sm text-gray-400 mb-1">{label}</div>
      <div className="text-2xl font-bold text-white">{value}</div>
    </div>
  );
}

interface FeatureCardProps {
  title: string;
  description: string;
}

function FeatureCard({ title, description }: FeatureCardProps) {
  return (
    <div className="bg-gray-800/50 rounded-lg p-4 border border-gray-700">
      <h3 className="font-semibold text-white mb-2">{title}</h3>
      <p className="text-sm text-gray-400">{description}</p>
    </div>
  );
}
