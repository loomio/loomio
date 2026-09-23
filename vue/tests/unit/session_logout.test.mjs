import assert from 'node:assert/strict';
import test from 'node:test';

import { signOutSession } from '../../src/shared/services/session_logout.mjs';

test('server logout does not wait for stalled browser push cleanup', async () => {
  let currentUserCleared = false;
  let destroyCount = 0;
  let reloadCount = 0;

  await signOutSession({
    disableBrowser: () => new Promise(() => {}),
    clearCurrentUser: () => { currentUserCleared = true; },
    destroySession: async () => { destroyCount += 1; },
    reload: () => { reloadCount += 1; }
  });

  assert.equal(currentUserCleared, true);
  assert.equal(destroyCount, 1);
  assert.equal(reloadCount, 1);
});

test('server logout continues when browser push cleanup raises', async () => {
  let destroyCount = 0;

  await signOutSession({
    disableBrowser: () => { throw new Error('service worker unavailable'); },
    clearCurrentUser: () => {},
    destroySession: async () => { destroyCount += 1; },
    reload: () => {}
  });

  assert.equal(destroyCount, 1);
});
