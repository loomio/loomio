import assert from 'node:assert/strict';
import test from 'node:test';

import {
  createPwaLifecycle,
  createPwaState,
  isIosSafari,
  serviceWorkerUrl,
} from '../../src/shared/services/pwa_lifecycle.mjs';

function browserWindow() {
  const value = new EventTarget();
  value.matchMedia = () => ({ matches: false });
  value.location = { reload() {} };
  return value;
}

function browserNavigator({ controller = null } = {}) {
  const serviceWorker = new EventTarget();
  serviceWorker.controller = controller;
  return {
    maxTouchPoints: 0,
    platform: 'Linux x86_64',
    serviceWorker,
    standalone: false,
    userAgent: 'Mozilla/5.0 Chrome/140.0.0.0 Safari/537.36',
  };
}

test('the install offer is retained until used and is then hidden even when dismissed', async () => {
  const window = browserWindow();
  const navigator = browserNavigator();
  const state = createPwaState(window, navigator);
  const lifecycle = createPwaLifecycle({ browserWindow: window, browserNavigator: navigator, state });
  let promptCount = 0;

  lifecycle.startInstallListeners();
  const event = new Event('beforeinstallprompt', { cancelable: true });
  event.prompt = async () => { promptCount += 1; };
  event.userChoice = Promise.resolve({ outcome: 'dismissed' });
  window.dispatchEvent(event);

  assert.equal(event.defaultPrevented, true);
  assert.equal(state.nativeInstallAvailable, true);
  assert.deepEqual(await lifecycle.promptInstall(), { outcome: 'dismissed' });
  assert.equal(promptCount, 1);
  assert.equal(state.nativeInstallAvailable, false);
  assert.equal(await lifecycle.promptInstall(), null);
});

test('iOS Add to Home Screen guidance is limited to non-standalone Safari', () => {
  const safari = {
    maxTouchPoints: 5,
    platform: 'iPhone',
    standalone: false,
    userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) Version/18.0 Mobile/15E148 Safari/604.1',
  };
  const chrome = { ...safari, userAgent: `${safari.userAgent} CriOS/140.0` };
  const standaloneWindow = browserWindow();
  standaloneWindow.matchMedia = () => ({ matches: true });

  assert.equal(isIosSafari(safari), true);
  assert.equal(isIosSafari(chrome), false);
  assert.equal(createPwaState(browserWindow(), safari).iosInstallAvailable, true);
  assert.equal(createPwaState(standaloneWindow, safari).iosInstallAvailable, false);
});

test('an accepted worker update waits for controllerchange before reloading', () => {
  const window = browserWindow();
  const navigator = browserNavigator({ controller: {} });
  const state = createPwaState(window, navigator);
  const messages = [];
  let updateCount = 0;
  let reloadCount = 0;
  window.location.reload = () => { reloadCount += 1; };

  const waiting = new EventTarget();
  waiting.state = 'installed';
  waiting.postMessage = message => messages.push(message);
  const registration = new EventTarget();
  registration.waiting = waiting;
  registration.installing = null;

  const lifecycle = createPwaLifecycle({
    browserWindow: window,
    browserNavigator: navigator,
    state,
    onUpdateAvailable: () => { updateCount += 1; },
  });
  lifecycle.watchRegistration(registration);

  assert.equal(state.workerUpdateAvailable, true);
  assert.equal(updateCount, 1);
  assert.equal(lifecycle.activateUpdate(), true);
  assert.deepEqual(messages, [{ type: 'SKIP_WAITING' }]);
  assert.equal(reloadCount, 0);

  navigator.serviceWorker.dispatchEvent(new Event('controllerchange'));
  navigator.serviceWorker.dispatchEvent(new Event('controllerchange'));
  assert.equal(reloadCount, 1);
});

test('an update activated by another tab falls back to a direct reload path', () => {
  const window = browserWindow();
  const navigator = browserNavigator({ controller: {} });
  const state = createPwaState(window, navigator);
  const messages = [];

  const waiting = new EventTarget();
  waiting.state = 'installed';
  waiting.postMessage = message => messages.push(message);
  const registration = new EventTarget();
  registration.waiting = waiting;
  registration.installing = null;

  const lifecycle = createPwaLifecycle({ browserWindow: window, browserNavigator: navigator, state });
  lifecycle.watchRegistration(registration);
  navigator.serviceWorker.dispatchEvent(new Event('controllerchange'));

  assert.equal(lifecycle.activateUpdate(), false);
  assert.deepEqual(messages, []);
});

test('a first service-worker install does not show an update notice', () => {
  const window = browserWindow();
  const navigator = browserNavigator();
  const state = createPwaState(window, navigator);
  let updateCount = 0;

  const installing = new EventTarget();
  installing.state = 'installing';
  const registration = new EventTarget();
  registration.installing = installing;
  registration.waiting = null;

  createPwaLifecycle({
    browserWindow: window,
    browserNavigator: navigator,
    state,
    onUpdateAvailable: () => { updateCount += 1; },
  }).watchRegistration(registration);

  installing.state = 'installed';
  installing.dispatchEvent(new Event('statechange'));
  assert.equal(updateCount, 0);
  assert.equal(state.workerUpdateAvailable, false);
});

test('the worker URL changes with both deployed app identifiers', () => {
  assert.equal(
    serviceWorkerUrl('3.0.0 beta', '2026-09-02.1'),
    '/service-worker.js?version=3.0.0%20beta&release=2026-09-02.1',
  );
});
