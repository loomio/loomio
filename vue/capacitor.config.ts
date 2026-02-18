import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'org.loomio.app',
  appName: 'Loomio',
  webDir: 'dist',
  server: {
    url: 'http://localhost:8080',
    cleartext: true,
  }
};

export default config;
