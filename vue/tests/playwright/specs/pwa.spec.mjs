import { test, expect } from '../fixtures.mjs';

test('serves home screen metadata and registers the push worker', async ({ page }) => {
  await page.goto('/dev/setup_group');
  await expect(page.locator('link[rel="manifest"]')).toHaveAttribute('href', '/manifest');

  const manifest = await (await page.request.get('/manifest')).json();
  expect(manifest).toMatchObject({ id: '/', scope: '/', display: 'standalone' });
  const maskable = manifest.icons.find(icon => icon.purpose === 'maskable');
  expect(maskable).toBeTruthy();
  expect((await page.request.get(maskable.src)).ok()).toBe(true);

  const worker = page.context().waitForEvent('serviceworker');
  await page.evaluate(() => navigator.serviceWorker.register('/service-worker.js'));
  expect((await worker).url()).toMatch(/\/service-worker\.js$/);
});
