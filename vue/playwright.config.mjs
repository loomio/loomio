import { defineConfig, devices } from '@playwright/test';
import { baseUrl } from './tests/playwright/helpers/pageHelper.mjs';

const screenshotLocale = process.env.DOCS_SCREENSHOT_APP_LOCALE?.replace('_', '-');

export default defineConfig({
  testDir: './tests/playwright/specs',
  outputDir: './tests/playwright/results',
  // Specs share one Rails server and test database.
  workers: 1,
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  timeout: 90_000,
  expect: { timeout: 8_000 },
  reporter: process.env.CI
    ? [['github'], ['list'], ['html', { open: 'never', outputFolder: './tests/playwright/report' }]]
    : [['list'], ['html', { open: 'never', outputFolder: './tests/playwright/report' }]],
  use: {
    ...devices['Desktop Chrome'],
    baseURL: baseUrl,
    viewport: { width: 1000, height: 2000 },
    locale: screenshotLocale || 'en-US',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    actionTimeout: 8_000,
  },
});
