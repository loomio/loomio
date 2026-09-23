import test from 'node:test';
import assert from 'node:assert/strict';
import { passkeyPlatformName } from '../../src/shared/helpers/passkey_name.mjs';

test('identifies common passkey platforms conservatively', () => {
  assert.equal(passkeyPlatformName({ platform: 'MacIntel', userAgent: '', maxTouchPoints: 0 }), 'Mac');
  assert.equal(passkeyPlatformName({ platform: 'MacIntel', userAgent: '', maxTouchPoints: 5 }), 'iPhone or iPad');
  assert.equal(passkeyPlatformName({ platform: 'Linux armv8l', userAgent: 'Mozilla/5.0 (Linux; Android 15)' }), 'Android');
  assert.equal(passkeyPlatformName({ userAgentData: { platform: 'Windows' }, platform: '', userAgent: '' }), 'Windows');
  assert.equal(passkeyPlatformName({ platform: 'Linux x86_64', userAgent: 'Mozilla/5.0 (X11; CrOS x86_64)' }), 'ChromeOS');
});

test('does not guess when the browser provides no recognized platform', () => {
  assert.equal(passkeyPlatformName({ platform: '', userAgent: '' }), undefined);
});

