import assert from 'node:assert/strict';
import test from 'node:test';

import { createNativeBridge } from '../../src/shared/services/native_bridge.mjs';

test('native bridge is unavailable in an ordinary browser', () => {
  assert.equal(createNativeBridge({}).available(), false);
});

test('native bridge sends only the versioned action envelope', async () => {
  const messages = [];
  const bridge = createNativeBridge({
    webkit: {
      messageHandlers: {
        loomioNative: {
          async postMessage(message) {
            messages.push(message);
            return { version: 1, platform: 'ios', push_registered: true };
          }
        }
      }
    }
  });

  assert.equal(bridge.available(), true);
  assert.equal((await bridge.invoke('getCapabilities')).push_registered, true);
  assert.deepEqual(messages, [{ version: 1, action: 'getCapabilities' }]);
});

test('native bridge rejects unexpected native responses', async () => {
  const bridge = createNativeBridge({
    webkit: {
      messageHandlers: {
        loomioNative: { postMessage: async () => ({ version: 2, platform: 'ios' }) }
      }
    }
  });

  await assert.rejects(bridge.invoke('getCapabilities'), /native_bridge_invalid_response/);
});
