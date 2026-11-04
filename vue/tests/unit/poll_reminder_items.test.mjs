import assert from 'node:assert/strict';
import test from 'node:test';
import { pollReminderItems } from '../../src/shared/helpers/poll_reminder_items.js';

test('reminder choices pair the uncast audience with the people who have not voted label', () => {
  assert.deepEqual(pollReminderItems(key => key), [
    { value: 'nobody', title: 'poll_common_settings.notify_on_closing_soon.nobody' },
    { value: 'author', title: 'poll_common_settings.notify_on_closing_soon.author' },
    { value: 'voters_uncast', title: 'poll_common_settings.notify_on_closing_soon.people_who_have_not_voted' },
    { value: 'voters', title: 'poll_common_settings.notify_on_closing_soon.voters' }
  ]);
});
