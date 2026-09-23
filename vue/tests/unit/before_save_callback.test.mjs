import assert from 'node:assert/strict';
import test from 'node:test';

import { registerBeforeSaveCallback } from '../../src/shared/helpers/before_save_callback.mjs';

test('registers a callback once and removes it during cleanup', () => {
  const model = { beforeSaves: [] };
  const callback = () => {};

  const cleanupFirst = registerBeforeSaveCallback(model, callback);
  const cleanupSecond = registerBeforeSaveCallback(model, callback);
  assert.deepEqual(model.beforeSaves, [callback]);

  cleanupFirst();
  cleanupSecond();
  assert.deepEqual(model.beforeSaves, []);
});

test('accepts a missing model during component transitions', () => {
  assert.doesNotThrow(() => registerBeforeSaveCallback(null, () => {})());
});
