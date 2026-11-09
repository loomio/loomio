import { beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({fetchItems: vi.fn(), openModal: vi.fn(), serverError: vi.fn()}));
vi.mock('@/shared/services/records', () => ({default: {topicItems: {fetch: mocks.fetchItems}}}));
vi.mock('@/shared/services/session', () => ({default: {}}));
vi.mock('@/shared/services/flash', () => ({default: {serverError: mocks.serverError}}));
vi.mock('@/shared/helpers/open_modal', () => ({default: mocks.openModal}));

import TopicService from '@/shared/services/topic_service';

describe('opening the thread tag editor', () => {
  beforeEach(() => vi.clearAllMocks());

  it('passes the loaded opening item without fetching', async () => {
    const topicItem = {id: 6, tags: ['Opening']};
    const topic = {id: 5, tags: ['Opening', 'Reply'], createdTopicItem: () => topicItem};

    await TopicService.actions(topic).edit_tags.perform();

    expect(mocks.fetchItems).not.toHaveBeenCalled();
    expect(mocks.openModal).toHaveBeenCalledWith({
      component: 'TopicTagsDialog', persistent: false, props: {topic, topicItem}
    });
  });

  it.each(['Discussion', 'Poll'])('fetches the opening %s item before opening the editor from the inbox', async topicableType => {
    let topicItem;
    let finishLoading;
    const topic = {id: 5, topicableType, tags: ['Opening', 'Reply'], createdTopicItem: () => topicItem};
    mocks.fetchItems.mockImplementationOnce(() => new Promise(resolve => { finishLoading = resolve; }));

    const action = TopicService.actions(topic).edit_tags.perform();

    expect(mocks.fetchItems).toHaveBeenCalledWith({params: {topic_id: 5, sequence_id: 0}});
    expect(mocks.openModal).not.toHaveBeenCalled();
    topicItem = {id: 6, tags: ['Opening']};
    finishLoading();
    await action;
    expect(mocks.openModal).toHaveBeenCalledWith({
      component: 'TopicTagsDialog', persistent: false, props: {topic, topicItem}
    });
  });

  it('reports a failed fetch without opening an editor with missing data', async () => {
    const error = new Error('Forbidden');
    const topic = {id: 5, createdTopicItem: () => undefined};
    mocks.fetchItems.mockRejectedValueOnce(error);

    await TopicService.actions(topic).edit_tags.perform();

    expect(mocks.serverError).toHaveBeenCalledWith(error);
    expect(mocks.openModal).not.toHaveBeenCalled();
  });
});
