import { Outlet, Link, useLocation } from 'react-router-dom';
import { Terminal, Layout as LayoutIcon, Play, Activity } from 'lucide-react';
import clsx from 'clsx';

export default function Layout() {
  const location = useLocation();

  const navItems = [
    { path: '/', label: 'Dashboard', icon: LayoutIcon },
    { path: '/scripts', label: 'Scripts', icon: Terminal },
    { path: '/executions', label: 'Executions', icon: Play },
  ];

  return (
    <div className="flex h-screen bg-gray-950">
      {/* Sidebar */}
      <aside className="w-64 bg-gray-900 border-r border-gray-800">
        <div className="p-6">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 bg-gradient-to-br from-cyan-500 to-blue-600 rounded-lg flex items-center justify-center">
              <Activity className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-xl font-bold text-white">Install Manager</h1>
              <p className="text-xs text-gray-400">Custom Scripts</p>
            </div>
          </div>
        </div>

        <nav className="px-3">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = location.pathname === item.path;

            return (
              <Link
                key={item.path}
                to={item.path}
                className={clsx(
                  'flex items-center space-x-3 px-3 py-2.5 rounded-lg mb-1 transition-colors',
                  isActive
                    ? 'bg-cyan-500/10 text-cyan-400'
                    : 'text-gray-400 hover:bg-gray-800 hover:text-white'
                )}
              >
                <Icon className="w-5 h-5" />
                <span className="font-medium">{item.label}</span>
              </Link>
            );
          })}
        </nav>

        <div className="absolute bottom-0 left-0 right-0 p-4 border-t border-gray-800">
          <div className="text-xs text-gray-500">
            <div className="flex items-center justify-between mb-1">
              <span>Version</span>
              <span className="text-gray-400">1.0.0</span>
            </div>
            <div className="flex items-center justify-between">
              <span>Status</span>
              <span className="flex items-center text-green-400">
                <span className="w-2 h-2 bg-green-400 rounded-full mr-2 animate-pulse"></span>
                Online
              </span>
            </div>
          </div>
        </div>
      </aside>

      {/* Main content */}
      <main className="flex-1 overflow-auto">
        <Outlet />
      </main>
    </div>
  );
}
