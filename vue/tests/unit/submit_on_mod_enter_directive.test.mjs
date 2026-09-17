import assert from 'node:assert/strict';
import test from 'node:test';
import directive, {isModEnter} from '../../src/submit_on_mod_enter_directive.js';

test('recognizes exact Ctrl+Enter and Command+Enter shortcuts', () => {
  assert.equal(isModEnter({key: 'Enter', ctrlKey: true, metaKey: false, altKey: false, shiftKey: false}), true);
  assert.equal(isModEnter({key: 'Enter', ctrlKey: false, metaKey: true, altKey: false, shiftKey: false}), true);
  assert.equal(isModEnter({key: 'Enter', ctrlKey: false, metaKey: false, altKey: false, shiftKey: false}), false);
  assert.equal(isModEnter({key: 'Enter', ctrlKey: true, metaKey: false, altKey: false, shiftKey: true}), false);
  assert.equal(isModEnter({key: 'Enter', ctrlKey: true, metaKey: true, altKey: false, shiftKey: false}), false);
});

test('prevents editor input and submits once for a non-repeating shortcut', () => {
  const listeners = {};
  const element = {
    addEventListener(name, listener, options) { listeners[name] = {listener, options}; },
    removeEventListener(name, listener, options) { assert.deepEqual(listeners[name], {listener, options}); }
  };
  let submissions = 0;
  directive.beforeMount(element, {value: () => submissions += 1});

  const event = {
    key: 'Enter', ctrlKey: true, metaKey: false, altKey: false, shiftKey: false, repeat: false,
    preventDefault() { this.wasPrevented = true; },
    stopPropagation() { this.wasStopped = true; }
  };
  listeners.keydown.listener(event);

  assert.equal(submissions, 1);
  assert.equal(event.wasPrevented, true);
  assert.equal(event.wasStopped, true);
  assert.deepEqual(listeners.keydown.options, {capture: true});

  event.repeat = true;
  listeners.keydown.listener(event);
  assert.equal(submissions, 1);

  directive.unmounted(element);
});
