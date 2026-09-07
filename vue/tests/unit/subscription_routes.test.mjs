import assert from 'node:assert/strict';
import test from 'node:test';

import {
  subscriptionManagementUrl,
  subscriptionUpgradeUrl
} from '../../src/shared/helpers/subscription_routes.mjs';

test('routes upgrades to the enabled subscription system', () => {
  assert.equal(subscriptionUpgradeUrl({
    baseUrl: 'https://loomio.example/',
    loomioSubscriptions: true,
    groupId: 42
  }), 'https://loomio.example/subscriptions/42');

  assert.equal(subscriptionUpgradeUrl({
    baseUrl: 'https://loomio.example/',
    loomioSubscriptions: false,
    groupId: 42
  }), 'https://loomio.example/upgrade/42');
});

test('routes subscription management through Loomio authorization', () => {
  assert.equal(subscriptionManagementUrl({
    baseUrl: 'https://loomio.example/',
    groupId: 42
  }), 'https://loomio.example/subscriptions/manage/42');
});
