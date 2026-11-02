import { test, expect } from '../fixtures.mjs';

test('registers_the_push_worker_and_serves_home_screen_metadata', async ({ page }) => {
  await page.goto('/dev/setup_group')
  await expect(page.locator('.group-page')).toBeVisible()

  const value = await page.evaluate(async () => {
    const manifestLink = document.querySelector('link[rel="manifest"]')
    const manifest = await (await fetch(manifestLink.href)).json()
    const maskableIcon = manifest.icons.find((icon) => icon.purpose === 'maskable')
    const iconResponse = await fetch(maskableIcon.src)
    await navigator.serviceWorker.register('/service-worker.js')
    const registration = await navigator.serviceWorker.ready
    return {
      manifestHref: manifestLink.getAttribute('href'),
      manifest,
      maskableIconAvailable: iconResponse.ok,
      workerScriptUrl: registration.active && registration.active.scriptURL
    }
  })

  expect(value.manifestHref).toBe('/manifest')
  expect(value.manifest.id).toBe('/')
  expect(value.manifest.scope).toBe('/')
  expect(value.manifest.display).toBe('standalone')
  expect(value.manifest.icons.some((icon) => icon.purpose === 'maskable')).toBe(true)
  expect(value.maskableIconAvailable).toBe(true)
  expect(value.workerScriptUrl).toMatch(/\/service-worker\.js$/)
});
