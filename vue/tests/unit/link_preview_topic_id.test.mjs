import assert from 'node:assert/strict';
import test from 'node:test';

import { linkPreviewTopicId } from '../../src/shared/helpers/link_preview_topic_id.js';

test('uses the direct topic id without resolving the topic', () => {
  let topicCalls = 0;
  const model = {
    topicId: 41,
    topic: () => {
      topicCalls += 1;
      return { id: 42 };
    },
  };

  assert.equal(linkPreviewTopicId(model), 41);
  assert.equal(topicCalls, 0);
});

test('uses the related topic id when the model has no direct topic id', () => {
  assert.equal(linkPreviewTopicId({ topic: () => ({ id: 42 }) }), 42);
});

test('omits the topic id for models without a topic relationship', () => {
  assert.equal(linkPreviewTopicId({}), undefined);
  assert.equal(linkPreviewTopicId({ topic: () => undefined }), undefined);
});
