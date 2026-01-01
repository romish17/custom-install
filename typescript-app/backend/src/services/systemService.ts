import { SystemInfo } from '../types';
import * as os from 'os';

export async function getSystemInfo(): Promise<SystemInfo> {
  return {
    platform: os.platform(),
    arch: os.arch(),
    hostname: os.hostname(),
    release: os.release(),
    uptime: os.uptime()
  };
}
