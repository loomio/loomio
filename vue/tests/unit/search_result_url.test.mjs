import assert from 'node:assert/strict';
import test from 'node:test';

import { urlForSearchResult } from '../../src/shared/helpers/search_result_url.mjs';

test('standalone polls use their poll route even when a sequence is present', () => {
  assert.equal(urlForSearchResult({
    searchable_type: 'Poll',
    poll_key: 'poll-key',
    poll_title: 'Standalone poll',
    discussion_key: null,
    discussion_title: null,
    sequence_id: 2,
  }), '/p/poll-key/standalone-poll');
});

test('discussion polls use their topic item route including sequence zero', () => {
  assert.equal(urlForSearchResult({
    searchable_type: 'Poll',
    poll_key: 'poll-key',
    poll_title: 'Poll title',
    discussion_key: 'discussion-key',
    discussion_title: 'Discussion title',
    sequence_id: 0,
  }), '/d/discussion-key/discussion-title/0');
});

test('missing titles do not raise while constructing a route', () => {
  assert.equal(urlForSearchResult({
    searchable_type: 'Outcome',
    poll_key: 'poll-key',
    poll_title: null,
    discussion_key: null,
    discussion_title: null,
    sequence_id: 3,
  }), '/p/poll-key/');
});
