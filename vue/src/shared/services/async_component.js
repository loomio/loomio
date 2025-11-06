import { defineAsyncComponent } from 'vue';
import { handleChunkError } from '@/shared/services/chunk_error_handling';

/**
 * Helper to create async components that will prompt the user to refresh
 * when a dynamic import fails due to missing/invalid chunk (404) or related
 * chunk load errors. The page reload only happens if the user confirms.
 *
 * Usage:
 *   import asyncComponent from '@/shared/services/async_component';
 *   const MyModal = asyncComponent(() => import('@/components/my/modal.vue'));
 *
 * Optionally pass through any defineAsyncComponent options:
 *   const MyModal = asyncComponent(() => import('@/components/my/modal.vue'), { delay: 0 });
 */

const DEFAULT_CONFIRM_MESSAGE = 'Loomio failed to load. Would you like to refresh the page?';

// Guard to avoid repeated reload loops
let isReloading = false;

/**
 * Best-effort detection of failures that are fixed by a hard reload:
 * - Missing/renamed code-split chunk (404)
 * - Browser/Vite dynamic import failures
 * - Generic chunk load errors
 */
function shouldReloadOnError(err) {
  if (!err) return false;

  const name = String(err.name || '');
  const message = String(err.message || err.toString?.() || '');
  const stack = String(err.stack || '');

  // Common chunk/dynamic import error signatures
  if (name === 'ChunkLoadError') return true;
  if (/ChunkLoadError/i.test(message)) return true;
  if (/Loading chunk \d+ failed/i.test(message)) return true;

  // Vite / browser dynamic import failures
  if (/Failed to fetch dynamically imported module/i.test(message)) return true;
  if (/Importing a module script failed/i.test(message)) return true;

  // Some environments surface generic "Failed to fetch" or network errors
  if (/NetworkError/i.test(message) || /Failed to fetch/i.test(message)) return true;

  // In some cases not found gets surfaced differently
  if (/ERR_MODULE_NOT_FOUND/i.test(message)) return true;
  if (/Cannot find module/i.test(message)) return true;

  // Fallback: check stack too (some browsers hide details in stack)
  if (/dynamic import/i.test(stack) && /failed|error|chunk/i.test(stack)) return true;

  return false;
}

/**
 * Show a confirmation prompt and reload only if the user agrees.
 * Returns true if a reload was initiated, false otherwise.
 */
function promptAndMaybeReload(confirmMessage = DEFAULT_CONFIRM_MESSAGE) {
  if (isReloading) return true;

  let confirmed = false;
  try {
    /* eslint-disable no-alert */
    confirmed = typeof window !== 'undefined'
      && typeof window.confirm === 'function'
      && window.confirm(confirmMessage);
    /* eslint-enable no-alert */
  } catch {
    // If confirm is blocked or unavailable, do not reload.
    confirmed = false;
  }

  if (!confirmed) return false;

  isReloading = true;

  try {
    window.location.reload();
  } catch {
    try {
      // Fallback: hard reload
      window.location.href = window.location.href;
    } catch {
      // Give up quietly
    }
  }
  return true;
}

/**
 * Wrap defineAsyncComponent with error handling that asks the user to
 * refresh the page when chunk load/404 failures occur.
 *
 * @param {() => Promise<any>} loader - The dynamic import function
 * @param {Object} [options] - Additional defineAsyncComponent options
 * @param {Function} [options.onError] - Optional user onError handler (called for non-reload errors)
 * @param {string} [options.confirmMessage] - Override the confirmation prompt message
 *
 * @returns {ReturnType<typeof defineAsyncComponent>}
 */
export default function asyncComponent(loader, options = {}) {
  if (typeof loader !== 'function') {
    throw new TypeError('asyncComponent expects a loader function: () => import("...")');
  }

  const {
    onError: userOnError,
    confirmMessage = DEFAULT_CONFIRM_MESSAGE,
    ...rest
  } = options;

  return defineAsyncComponent({
    loader,
    ...rest,
    onError(err, retry, fail, attempts) {
      const { handled, reloading } = handleChunkError(err, { confirmMessage });
      if (handled) {
        if (reloading) {
          return;
        }
        return fail(err);
      }

      // Delegate to user handler if provided
      if (typeof userOnError === 'function') {
        try {
          return userOnError(err, retry, fail, attempts);
        } catch (e) {
          return fail(e);
        }
      }

      // Default behavior: fail the component load so the error surface is visible
      return fail(err);
    }
  });
}
