import assert from 'node:assert/strict';
import test from 'node:test';

import { taskRecordTitle } from '../../src/shared/helpers/task_record_title.mjs';

const record = (type, attributes = {}) => ({
  ...attributes,
  isA: candidate => candidate === type,
});

test('uses the containing topic title for comment tasks', () => {
  const comment = record('comment', { topic: () => ({ title: 'Thread title' }) });
  assert.equal(taskRecordTitle(comment), 'Thread title');
});

test('uses the poll title for outcome tasks', () => {
  const outcome = record('outcome', { poll: () => ({ title: 'Poll title' }) });
  assert.equal(taskRecordTitle(outcome), 'Poll title');
});

test('uses native titles for discussions and polls', () => {
  assert.equal(taskRecordTitle(record('discussion', { title: 'Discussion title' })), 'Discussion title');
  assert.equal(taskRecordTitle(record('poll', { title: 'Poll title' })), 'Poll title');
});

test('uses the group name for group tasks', () => {
  assert.equal(taskRecordTitle(record('group', { name: 'Group name' })), 'Group name');
});
