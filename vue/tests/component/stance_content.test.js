import { shallowMount } from '@vue/test-utils';
import { h } from 'vue';
import { afterEach, describe, expect, it, vi } from 'vitest';

vi.mock('@/shared/services/stance_service', () => ({default: {actions: () => ({})}}));
vi.mock('@/shared/services/records', () => ({default: {}}));
vi.mock('@/shared/services/session', () => ({default: {}}));
vi.mock('@/i18n', () => ({I18n: {}}));
vi.mock('@/shared/services/lmo_url_service', () => ({default: {topic_item: () => '/d/thread/1'}}));
vi.mock('@/mixins/url_for', () => ({default: {}}));
vi.mock('vue-i18n', () => ({useI18n: () => ({t: key => key})}));

import StanceCreated from '@/components/topic_items/stance_created.vue';
import StanceUpdated from '@/components/topic_items/stance_updated.vue';

let wrapper;
afterEach(() => wrapper?.unmount());

function render(component, {showResults = true, collapsed = false, ...attributes} = {}) {
  const itemable = {
    castAt: new Date(), latest: true, reason: '<p>A long reason</p>'.repeat(30) + '<p>Final paragraph</p>',
    poll: () => ({showResults: () => showResults}), hasOptionIcon: () => false,
    ...attributes
  };
  wrapper = shallowMount(component, {
    props: {topic_item: {actor: () => null, actorName: () => 'Alex'}, itemable, collapsed},
    global: {
      mocks: {$t: key => key},
      directives: {t: {}},
      stubs: {
        StanceUpdated: false,
        RouterLink: true,
        formatted_text: {props: ['model', 'field'], render() { return h('div', {innerHTML: this.model[this.field]}); }}
      }
    }
  });
  return wrapper;
}

describe.each([
  ['original vote', StanceCreated],
  ['updated vote', StanceUpdated]
])('%s reasons', (_name, component) => {
  it('renders the full permitted reason', () => {
    render(component);
    const reason = wrapper.get('.poll-common-stance-created__reason');
    expect(reason.findAll('p')).toHaveLength(31);
    expect(reason.text()).toContain('Final paragraph');
  });

  it.each([
    {showResults: false},
    {redactedAt: new Date()},
    {revokedAt: new Date()},
    {castAt: null},
    {collapsed: true}
  ])('keeps restricted reasons hidden for %o', attributes => {
    render(component, attributes);
    expect(wrapper.find('.poll-common-stance-created__reason').exists()).toBe(false);
    expect(wrapper.text()).not.toContain('Final paragraph');
  });
});
