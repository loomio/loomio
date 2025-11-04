/**
 * Shared utilities for detecting and handling failed dynamic-import/chunk-load errors.
 *
 * Typical causes:
 * - App deploy changed code-split chunk filenames; client still holds old manifest
 * - Network hiccups during route/component lazy load
 * - Browser reports generic "Failed to fetch dynamically imported module"
 *
 * Usage patterns:
 * 1) Global router handler:
 *    import { installRouterChunkErrorHandler } from '@/shared/services/chunk_error_handling'
 *    installRouterChunkErrorHandler(router)
 *
 * 2) Wrap an async route/component loader:
 *    import { wrapAsyncLoader } from '@/shared/services/chunk_error_handling'
 *    const MyPage = wrapAsyncLoader(() => import('@/components/my/page.vue'))
 *
 * 3) Use isChunkOrDynamicImportError + promptAndMaybeReload manually where needed.
 */

export const DEFAULT_CONFIRM_MESSAGE =
  'Loomio failed to load. Would you like to refresh the page?'

// Prevent multiple simultaneous reload attempts within the same page lifecycle
let isReloading = false

/**
 * Best-effort detection of failures that are fixed by a hard reload:
 * - Missing/renamed code-split chunk (404)
 * - Browser/Vite dynamic import failures
 * - Generic chunk load errors
 */
export function isChunkOrDynamicImportError(err) {
  if (!err) return false

  const name = String(err.name || '')
  const message = String(err.message || err.toString?.() || '')
  const stack = String(err.stack || '')

  // Common chunk/dynamic import error signatures
  if (name === 'ChunkLoadError') return true
  if (/ChunkLoadError/i.test(message)) return true
  if (/Loading chunk \d+ failed/i.test(message)) return true

  // Vite / browser dynamic import failures
  if (/Failed to fetch dynamically imported module/i.test(message)) return true
  if (/Importing a module script failed/i.test(message)) return true

  // Some environments surface generic "Failed to fetch" or network errors
  if (/NetworkError/i.test(message) || /Failed to fetch/i.test(message)) return true

  // Module not found in certain runtimes
  if (/ERR_MODULE_NOT_FOUND/i.test(message)) return true
  if (/Cannot find module/i.test(message)) return true

  // Fallback: check stack too (some browsers hide details in stack)
  if (/dynamic import/i.test(stack) && /failed|error|chunk/i.test(stack)) return true

  return false
}

/**
 * Show a confirmation prompt and reload only if the user agrees.
 * Returns true if a reload was initiated, false otherwise.
 */
export function promptAndMaybeReload(confirmMessage = DEFAULT_CONFIRM_MESSAGE) {
  if (isReloading) return true

  let confirmed = false
  try {
    /* eslint-disable no-alert */
    confirmed =
      typeof window !== 'undefined' &&
      typeof window.confirm === 'function' &&
      window.confirm(confirmMessage)
    /* eslint-enable no-alert */
  } catch {
    // If confirm is blocked or unavailable, do not reload.
    confirmed = false
  }

  if (!confirmed) return false

  isReloading = true

  try {
    window.location.reload()
  } catch {
    try {
      // Fallback: hard reload
      window.location.href = window.location.href
    } catch {
      // Give up quietly
    }
  }
  return true
}

/**
 * Handle an error that might be a chunk/dynamic import failure.
 * - If it is, prompt to reload (and reload when accepted).
 * - If not, pass to onNonReloadError (if provided), otherwise do nothing.
 *
 * Returns an object:
 *  - handled: boolean (true if this function took an action or decided not to)
 *  - reloading: boolean (true if a reload was initiated)
 */
export function handleChunkError(
  err,
  {
    confirmMessage = DEFAULT_CONFIRM_MESSAGE,
    onNonReloadError,
  } = {}
) {
  if (isChunkOrDynamicImportError(err)) {
    const reloading = promptAndMaybeReload(confirmMessage)
    return { handled: true, reloading }
  }

  if (typeof onNonReloadError === 'function') {
    try {
      onNonReloadError(err)
    } catch {
      // Swallow secondary errors to avoid masking the original
    }
  }

  return { handled: false, reloading: false }
}

/**
 * Wrap a lazy loader (() => import('...')) to automatically handle
 * chunk/dynamic import failures with a confirm-and-reload flow.
 *
 * Example:
 *   const Page = wrapAsyncLoader(() => import('@/components/page.vue'))
 */
export function wrapAsyncLoader(loader, { confirmMessage = DEFAULT_CONFIRM_MESSAGE } = {}) {
  if (typeof loader !== 'function') {
    throw new TypeError('wrapAsyncLoader expects a loader function: () => import("...")')
  }

  return () =>
    Promise.resolve()
      .then(loader)
      .catch((err) => {
        handleChunkError(err, { confirmMessage })
        // Re-throw so upstream (router/Vue) can surface the failure if user declined reload
        throw err
      })
}

/**
 * Install a global router error handler that prompts the user to refresh
 * on chunk/dynamic import failures during navigation.
 *
 * Safe to call multiple times; each call registers another handler.
 */
export function installRouterChunkErrorHandler(router, { confirmMessage = DEFAULT_CONFIRM_MESSAGE } = {}) {
  if (!router || typeof router.onError !== 'function') {
    throw new TypeError('installRouterChunkErrorHandler expects a Vue Router instance with onError(fn)')
  }

  router.onError((err) => {
    // Only react to chunk/dynamic import errors; let other errors flow
    if (isChunkOrDynamicImportError(err)) {
      handleChunkError(err, { confirmMessage })
      // Intentionally no throw; allow router to continue its own error handling
    }
  })
}

// Optional default export for convenience
export default {
  DEFAULT_CONFIRM_MESSAGE,
  isChunkOrDynamicImportError,
  promptAndMaybeReload,
  handleChunkError,
  wrapAsyncLoader,
  installRouterChunkErrorHandler,
}