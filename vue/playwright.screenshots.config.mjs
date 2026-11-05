import { defineConfig } from '@playwright/test';
import base from './playwright.config.mjs';

// User-manual screenshots run on request (bin/e2e-screenshots), never in CI.
export default defineConfig({
  ...base,
  testDir: './tests/playwright/screenshots',
  outputDir: './tests/playwright/screenshot-results',
  retries: 0,
  reporter: [['list']],
  use: {
    ...base.use,
    deviceScaleFactor: Number(process.env.SCREENSHOT_DEVICE_SCALE_FACTOR || 2),
    colorScheme: 'light',
    trace: 'off',
  },
});
