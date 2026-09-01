import assert from 'node:assert/strict';
import test from 'node:test';

import {
  notificationCatchUpTitleKey,
  notificationVolumeOptionDescriptionKey,
  notificationVolumeOptionTitleKey,
} from '../../src/shared/helpers/notification_volume_options.js';

test('catch-up title describes its configured frequency', () => {
  assert.equal(notificationCatchUpTitleKey(7), 'strand_nav.daily_catch_up_email');
  assert.equal(notificationCatchUpTitleKey(8), 'strand_nav.catch_up_email_every_second_day');
  assert.equal(notificationCatchUpTitleKey(1), 'strand_nav.weekly_catch_up_email');
});

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
