import { Script } from '../types';
import path from 'path';

// In-memory script database (in production, this would come from a database)
const scripts: Script[] = [
  {
    id: 'kali-cyberpunk',
    name: 'Kali Cyberpunk Theme',
    description: 'Install and configure Cyberpunk 2077 theme for KDE Plasma on Kali Linux',
    platform: 'kali',
    category: 'Personalization',
    path: '../../../kali-custom.sh',
    enabled: true
  },
  {
    id: 'windows-post-install',
    name: 'Windows Post-Installation',
    description: 'Complete Windows post-installation configuration: disable bloatware, install essential software, optimize privacy',
    platform: 'windows',
    category: 'System Configuration',
    path: '../../../windoz/post-install.ps1',
    enabled: true
  },
  {
    id: 'windows-gui',
    name: 'Windows GUI Configuration',
    description: 'Advanced Windows GUI customization and optimization',
    platform: 'windows',
    category: 'Personalization',
    path: '../../../windoz/Win-GUI.ps1',
    enabled: true
  },
  {
    id: 'debian-docker',
    name: 'Docker Installation (Debian)',
    description: 'Install and configure Docker on Debian-based systems',
    platform: 'linux',
    category: 'Development',
    path: '../../../debian/docker.sh',
    enabled: true
  },
  {
    id: 'debian-fail2ban',
    name: 'Fail2ban Setup',
    description: 'Install and configure Fail2ban for security',
    platform: 'linux',
    category: 'Security',
    path: '../../../debian/fail2ban.sh',
    enabled: true
  }
];

export async function getScripts(platform?: string): Promise<Script[]> {
  if (platform) {
    return scripts.filter(s => s.platform === platform);
  }
  return scripts;
}

export async function getScript(id: string): Promise<Script | undefined> {
  return scripts.find(s => s.id === id);
}

export function getScriptPath(scriptId: string): string | null {
  const script = scripts.find(s => s.id === scriptId);
  if (!script) return null;

  return path.resolve(__dirname, script.path);
}
