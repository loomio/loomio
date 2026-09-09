import assert from 'node:assert/strict';
import test from 'node:test';

import { requiresHomeScreen } from '../../src/shared/services/push_subscription_support.mjs';

function browserWindow(standalone = false) {
  return { matchMedia: () => ({ matches: standalone }) };
}

const iosNavigator = {
  maxTouchPoints: 5,
  platform: 'iPhone',
  standalone: false,
  userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148 Safari/604.1',
};

test('iPhone and iPad browsers require Home Screen installation for push', () => {
  assert.equal(requiresHomeScreen(browserWindow(), iosNavigator), true);
  assert.equal(requiresHomeScreen(browserWindow(), {
    ...iosNavigator,
    platform: 'MacIntel',
    userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15) AppleWebKit/605.1.15 Version/18.0 Mobile/15E148 Safari/604.1',
  }), true);
});

test('an iOS Home Screen app can enable push', () => {
  assert.equal(requiresHomeScreen(browserWindow(true), iosNavigator), false);
  assert.equal(requiresHomeScreen(browserWindow(), { ...iosNavigator, standalone: true }), false);
});

test('other browsers do not require Home Screen installation for push', () => {
  const navigator = {
    maxTouchPoints: 0,
    platform: 'Linux x86_64',
    standalone: false,
    userAgent: 'Mozilla/5.0 Chrome/140.0.0.0 Safari/537.36',
  };

  assert.equal(requiresHomeScreen(browserWindow(), navigator), false);
});
