import assert from 'node:assert/strict';
import test from 'node:test';

import {
  notificationVolumeOptionDescriptionKey,
  notificationVolumeOptionTitleKey,
} from '../../src/shared/helpers/notification_volume_options.js';

test('catch-up wording only applies to email options', () => {
  assert.equal(
    notificationVolumeOptionTitleKey('quiet', 'email', true),
    'change_volume_form.catch_up_only_option',
  );
  assert.equal(
    notificationVolumeOptionDescriptionKey('normal', 'email', true),
    'change_volume_form.email_when_notified_with_catch_up_description',
  );

  assert.equal(
    notificationVolumeOptionTitleKey('quiet', 'push', true),
    'change_volume_form.no_push_updates_option',
  );
  assert.equal(
    notificationVolumeOptionDescriptionKey('quiet', 'push', true),
    'change_volume_form.no_push_updates_description',
  );
  assert.equal(
    notificationVolumeOptionDescriptionKey('normal', 'push', true),
    'change_volume_form.push_when_notified_description',
  );
});
