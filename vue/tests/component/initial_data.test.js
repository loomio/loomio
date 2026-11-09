import { beforeEach, describe, expect, it, vi } from 'vitest';
import { createMemoryHistory, createRouter } from 'vue-router';

const params = {discussion_key: 'thread-key', include_polls_not_closed: 1, limit: 25, unread_or_newest: 1};
const path = '/api/v1/topic_items';
const records = {topics: [{id: 12}], topic_items: [{id: 34, topic_id: 12}]};

beforeEach(() => {
  vi.resetModules();
  document.body.innerHTML = '';
  history.replaceState({}, '', '/dashboard');
});

function embed() {
  const element = document.createElement('script');
  element.id = 'initial-data';
  element.type = 'application/json';
  element.textContent = JSON.stringify({boot: {current_user_id: 5}, requests: [{path, params, records}]});
  document.body.appendChild(element);
}

describe('initial response data', () => {
  it('omits groups from content reads after boot while keeping explicit group fetches', async () => {
    const {default: AppConfig} = await import('@/shared/services/app_config');
    const {default: RestfulClient} = await import('@/shared/record_store/restful_client');
    AppConfig.groupsLoaded = true;
    const client = new RestfulClient('topic_items');
    client.request = vi.fn().mockResolvedValue({});
    await client.get('', {exclude_types: 'topic'});
    expect(new URL(client.request.mock.calls[0][0], location.origin).searchParams.get('exclude_types')).toBe('topic group');
    const groupClient = new RestfulClient('groups');
    groupClient.request = vi.fn().mockResolvedValue({});
    await groupClient.get('some-group', {});
    expect(new URL(groupClient.request.mock.calls[0][0], location.origin).searchParams.has('exclude_types')).toBe(false);
    AppConfig.groupsLoaded = false;
    await client.get('', {});
    expect(new URL(client.request.mock.calls[1][0], location.origin).searchParams.has('exclude_types')).toBe(false);
  });

  it('consumes the matching window once, allowing later visits to fetch fresh records', async () => {
    embed();
    const {bootData, takeInitialResponse} = await import('@/shared/services/initial_data');
    expect(bootData.current_user_id).toBe(5);
    expect(document.getElementById('initial-data')).toBeNull();
    expect(takeInitialResponse(path, {...params})).toEqual(records);
    expect(takeInitialResponse(path, params)).toBeUndefined();
  });

  it.each([
    {...params, discussion_key: 'another-thread'},
    {discussion_key: 'thread-key', include_polls_not_closed: 1, limit: 25, sequence_id_gte: 50, order: 'sequence_id'}
  ])('does not use records for a different thread or window', async changed => {
    embed();
    const {takeInitialResponse} = await import('@/shared/services/initial_data');
    expect(takeInitialResponse(path, changed)).toBeUndefined();
    expect(takeInitialResponse(path, params)).toEqual(records);
  });

  it('leaves other pages on the ordinary API boot path', async () => {
    const {bootData, takeInitialResponse} = await import('@/shared/services/initial_data');
    expect(bootData).toBeUndefined();
    expect(takeInitialResponse(path, params)).toBeUndefined();
  });

  async function initialRouter() {
    const {clearInitialDataAfterNavigation} = await import('@/shared/services/initial_data');
    const router = createRouter({history: createMemoryHistory(), routes: [
      {path: '/', redirect: '/dashboard'},
      {path: '/dashboard', component: {}},
      {path: '/inbox', component: {}}
    ]});
    router.afterEach(clearInitialDataAfterNavigation);
    await router.replace('/');
    return router;
  }

  it('retains initial responses through the initial root redirect', async () => {
    embed();
    const {takeInitialResponse} = await import('@/shared/services/initial_data');
    const router = await initialRouter();
    expect(router.currentRoute.value.path).toBe('/dashboard');
    expect(takeInitialResponse(path, params)).toEqual(records);
  });

  it('discards unused responses after navigation and does not restore them on return', async () => {
    embed();
    const {takeInitialResponse} = await import('@/shared/services/initial_data');
    const router = await initialRouter();
    await router.push('/inbox');
    expect(takeInitialResponse(path, params)).toBeUndefined();
    await router.push('/dashboard');
    expect(takeInitialResponse(path, params)).toBeUndefined();
  });

  it('discards unused responses when the session changes', async () => {
    embed();
    const {takeInitialResponse, clearInitialData} = await import('@/shared/services/initial_data');
    clearInitialData();
    expect(takeInitialResponse(path, params)).toBeUndefined();
  });

  it('uses the same import callback as an API response and fetches again on refresh', async () => {
    embed();
    const {default: RestfulClient} = await import('@/shared/record_store/restful_client');
    const client = new RestfulClient('topic_items');
    client.onSuccess = vi.fn(data => data);
    client.request = vi.fn().mockResolvedValue({topic_items: []});
    expect(await client.get('', params)).toEqual(records);
    expect(client.onSuccess).toHaveBeenCalledWith(records);
    expect(client.request).not.toHaveBeenCalled();
    await client.get('', params);
    expect(client.request).toHaveBeenCalledOnce();
  });
});
