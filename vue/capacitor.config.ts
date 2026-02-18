import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'org.loomio.app',
  appName: 'Loomio',
  webDir: 'dist',
  server: {
    // For development, uncomment and point to your Vite dev server:
    // url: 'http://YOUR_LOCAL_IP:8080',
    // cleartext: true,
  }
};

export default config;
