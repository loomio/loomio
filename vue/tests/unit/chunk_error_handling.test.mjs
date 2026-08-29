import assert from 'node:assert/strict'
import { readFile } from 'node:fs/promises'
import test from 'node:test'

async function importChunkErrorHandling() {
  const sourceUrl = new URL('../../src/shared/services/chunk_error_handling.js', import.meta.url)
  const source = await readFile(sourceUrl, 'utf8')
  const encodedSource = Buffer.from(source).toString('base64')
  return import(`data:text/javascript;base64,${encodedSource}#${crypto.randomUUID()}`)
}

test('an accepted missing-chunk reload does not resolve an undefined route component', async (t) => {
  const originalWindow = globalThis.window
  const browserWindow = new EventTarget()
  let confirmCount = 0
  let reloadCount = 0

  browserWindow.confirm = () => {
    confirmCount += 1
    return true
  }
  browserWindow.location = {
    reload() { reloadCount += 1 },
  }
  globalThis.window = browserWindow
  t.after(() => { globalThis.window = originalWindow })

  const { installVitePreloadErrorHandler, wrapAsyncLoader } = await importChunkErrorHandling()
  installVitePreloadErrorHandler()

  const preloadError = new Event('vite:preloadError', { cancelable: true })
  preloadError.payload = new TypeError('Failed to fetch dynamically imported module')
  browserWindow.dispatchEvent(preloadError)

  assert.equal(preloadError.defaultPrevented, true)
  assert.equal(confirmCount, 1)
  assert.equal(reloadCount, 1)

  const loadRoute = wrapAsyncLoader(() => Promise.resolve(undefined))
  const result = await Promise.race([
    loadRoute().then(() => 'resolved', () => 'rejected'),
    new Promise((resolve) => setTimeout(() => resolve('pending'), 20)),
  ])

  assert.equal(result, 'pending')
})

test('a successfully loaded route component still resolves normally', async () => {
  const { wrapAsyncLoader } = await importChunkErrorHandling()
  const component = { default: { name: 'LazyPage' } }

  assert.equal(await wrapAsyncLoader(() => Promise.resolve(component))(), component)
})

test('a declined missing-chunk reload still rejects the route load', async (t) => {
  const originalWindow = globalThis.window
  const browserWindow = new EventTarget()
  let confirmCount = 0

  browserWindow.confirm = () => {
    confirmCount += 1
    return false
  }
  browserWindow.location = { reload() {} }
  globalThis.window = browserWindow
  t.after(() => { globalThis.window = originalWindow })

  const { wrapAsyncLoader } = await importChunkErrorHandling()
  const chunkError = new TypeError('Failed to fetch dynamically imported module')

  await assert.rejects(wrapAsyncLoader(() => Promise.reject(chunkError))(), chunkError)
  assert.equal(confirmCount, 1)
})
