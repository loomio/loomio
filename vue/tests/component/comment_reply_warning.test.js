import { mount, flushPromises } from '@vue/test-utils';
import { reactive } from 'vue';
import { createVuetify } from 'vuetify';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

vi.hoisted(() => { window.Loomio = {}; });
vi.mock('@/shared/services/session', () => ({default: {user: () => ({id: 1})}}));
vi.mock('@/shared/services/records', () => ({default: {}}));
vi.mock('@/shared/services/ability_service', () => ({default: {}}));
vi.mock('@/shared/services/subscription_service', () => ({default: {upgradeUrl: () => '/upgrade'}}));
vi.mock('@sentry/vue', () => ({metrics: {count: vi.fn()}}));
vi.mock('@/components/user/avatar.vue', () => ({default: {template: '<div />'}}));
vi.mock('@/components/lmo_textarea/lmo_textarea.vue', () => ({default: {
  props: ['model'],
  template: '<div><textarea v-model="model.body" /><slot name="actions" /></div>'
}}));

import CommentForm from '@/components/topic/comment_form.vue';
import FlashMessage from '@/components/common/flash.vue';
import EventBus from '@/shared/services/event_bus';
import RestfulClient from '@/shared/record_store/restful_client';

const warning = 'The item you are replying to has been deleted';
const draft = 'A reply I want to keep';

describe('posting a comment to an unavailable parent', () => {
  let wrapper;
  let comment;
  let emit;

  beforeEach(() => {
    vi.stubGlobal('ResizeObserver', class { observe() {} unobserve() {} disconnect() {} });
    vi.stubGlobal('visualViewport', undefined);
    vi.stubGlobal('matchMedia', () => ({matches: false, addEventListener() {}, removeEventListener() {}}));
    vi.spyOn(console, 'warn').mockImplementation(() => {});
    emit = vi.spyOn(EventBus, '$emit');
    const parent = {
      isA: type => type === 'comment',
      author: () => ({nameOrUsername: () => 'Alex'}),
      topic: () => ({commentLengthMax: null})
    };
    const client = new RestfulClient('comments');
    comment = reactive({
      id: null,
      parentId: 41,
      body: draft,
      parent: () => parent,
      author: () => ({id: 1}),
      isNew: () => true,
      isReply: () => true,
      save: () => client.create({comment: {parent_type: 'Comment', parent_id: 41, body: comment.body}})
    });
  });

  afterEach(() => {
    if (wrapper) {
      clearInterval(wrapper.findComponent(FlashMessage).vm.timer);
      wrapper.unmount();
    }
    EventBus.$off('flashMessage');
    document.body.innerHTML = '';
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  function mountForm() {
    wrapper = mount({
      components: {CommentForm, FlashMessage},
      setup: () => ({comment}),
      template: '<div><FlashMessage /><CommentForm :comment="comment" /></div>'
    }, {
      attachTo: document.body,
      global: {
        plugins: [createVuetify()],
        mocks: {$t: key => key},
        directives: {t: (element, binding) => { element.textContent = binding.value; }}
      }
    });
  }

  it('shows the server warning after Post and retains the draft', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(new Response(JSON.stringify({flash: {error: warning}}), {
      status: 422, statusText: 'Unprocessable Entity'
    })));
    mountForm();

    await wrapper.find('.comment-form__submit-button').trigger('click');
    await flushPromises();

    expect(fetch).toHaveBeenCalledWith('/api/v1/comments', expect.objectContaining({method: 'POST'}));
    expect(document.querySelector('.flash-root__message').textContent).toBe(warning);
    expect(wrapper.find('textarea').element.value).toBe(draft);
    expect(comment.body).toBe(draft);
    expect(wrapper.findComponent(CommentForm).emitted('comment-submitted')).toBeUndefined();
    expect(emit.mock.calls.some(([event]) => event === 'deleteDraft')).toBe(false);
    expect(wrapper.findComponent(CommentForm).vm.processing).toBe(false);
  });

});
