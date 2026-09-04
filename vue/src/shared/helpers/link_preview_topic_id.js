export const linkPreviewTopicId = (model) =>
  model.topicId || model.topic?.()?.id;
