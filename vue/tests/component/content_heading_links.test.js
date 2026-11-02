import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { mount } from '@vue/test-utils';
import { createVuetify } from 'vuetify';
import { createI18n } from 'vue-i18n';
import ContentHeadingLinks from '@/components/common/content_heading_links.vue';
import FormattedText from '@/components/common/formatted_text.vue';
import TopicHeadingsService from '@/shared/services/topic_headings_service';
import ScrollService from '@/shared/services/scroll_service';
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import marked from '@/marked_directive';

vi.mock('@/shared/services/scroll_service', () => ({default: {scrollToSettled: vi.fn()}}));
vi.mock('@/shared/services/records', () => ({default: {remote: {get: vi.fn()}, topicItems: {find: vi.fn()}}}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: vi.fn()}}));
vi.mock('@/shared/services/session', () => ({default: {}}));
vi.mock('@/shared/services/flash', () => ({default: {}}));
vi.mock('@/shared/services/ability_service', () => ({default: {canEdit: () => false}}));

const wrappers = [];
const roots = [];
const heading = {title: 'Agenda', level: 2, index: 1, topic_item_id: 123, sequence_id: 42,
  model_type: 'comment', model_id: 7, field: 'body'};

beforeEach(() => vi.clearAllMocks());
afterEach(() => {
  wrappers.splice(0).forEach(wrapper => wrapper.unmount());
  roots.splice(0).forEach(root => root.remove());
});

function content(html) {
  const root = document.createElement('section');
  root.innerHTML = html;
  document.body.appendChild(root);
  roots.push(root);
  return root;
}

function loader() {
  const parent = {id: 1, parent: () => null};
  Records.topicItems.find.mockReturnValue({id: 123, parent: () => parent});
  return {addLoadSequenceIdRule: vi.fn(), fetch: vi.fn().mockResolvedValue(), updateCollection: vi.fn(), expand: vi.fn()};
}

describe('thread heading navigation', () => {
  it('renders heading labels and hierarchy and emits the selected entry', async () => {
    const entries = [{...heading, level: 1}, {...heading, topic_item_id: 456, level: 6}];
    const wrapper = mount(ContentHeadingLinks, {props: {headings: entries}, global: {plugins: [createVuetify()]}});
    wrappers.push(wrapper);
    const links = wrapper.findAll('button');
    expect(links.map(link => link.text())).toEqual(['Agenda', 'Agenda']);
    expect(links.map(link => link.element.style.paddingInlineStart)).toEqual(['16px', '76px']);
    await links[1].trigger('click');
    expect(wrapper.emitted('selected')).toEqual([[entries[1]]]);
  });

  it('fetches the whole outline, including pages with no headings', async () => {
    const section = {topic_item_id: 123, headings: [heading]};
    Records.remote.get.mockResolvedValueOnce({sections: [], meta: {next_offset: 200}})
      .mockResolvedValueOnce({sections: [section], meta: {next_offset: null}});
    expect(await TopicHeadingsService.fetch(9)).toEqual([section]);
    expect(Records.remote.get.mock.calls).toEqual([
      ['topic_items/headings', {topic_id: 9, limit: 200, offset: 0}],
      ['topic_items/headings', {topic_id: 9, limit: 200, offset: 200}]
    ]);
  });

  it('stops fetching an obsolete outline when the thread changes', async () => {
    Records.remote.get.mockResolvedValue({sections: [], meta: {next_offset: 200}});
    expect(await TopicHeadingsService.fetch(9, () => true)).toEqual([]);
    expect(Records.remote.get).toHaveBeenCalledOnce();
  });

  it('loads the containing contribution, expands its ancestry and focuses the selected duplicate heading', async () => {
    const root = content('<div class="sequenceId-10"><div data-content-model="comment-7" data-content-field="body"><h2>Agenda</h2><h2>Agenda</h2></div></div><div class="sequenceId-42"><div data-content-model="comment-7" data-content-field="body"><h2></h2><h2 id="agenda">Agenda</h2></div></div>');
    const target = root.querySelector('.sequenceId-42 h2:last-child');
    const threadLoader = loader();
    const cancel = vi.fn();
    ScrollService.scrollToSettled.mockReturnValue(cancel);
    expect(await TopicHeadingsService.jumpTo(heading, threadLoader)).toBe(cancel);
    expect(threadLoader.addLoadSequenceIdRule).toHaveBeenCalledWith(42);
    expect(threadLoader.fetch).toHaveBeenCalledOnce();
    expect(threadLoader.updateCollection).toHaveBeenCalledOnce();
    expect(threadLoader.expand.mock.calls.map(([item]) => item.id)).toEqual([123, 1]);
    expect(document.activeElement).toBe(target);
    expect(target.id).toBe('agenda');
    expect(EventBus.$emit).toHaveBeenCalledWith('setAnchor', '[data-content-heading="123-body-1"]', 72);
    expect(ScrollService.scrollToSettled).toHaveBeenCalledWith('[data-content-heading="123-body-1"]');
  });

  it('does not scroll when a later selection supersedes the pending load', async () => {
    const threadLoader = loader();
    await TopicHeadingsService.jumpTo(heading, threadLoader, () => true);
    expect(threadLoader.updateCollection).not.toHaveBeenCalled();
    expect(ScrollService.scrollToSettled).not.toHaveBeenCalled();
  });

  it('renders translated Markdown-source content as HTML and exposes a field-specific jump target', () => {
    class Comment {
      static singular = 'comment';
      id = 7;
      body = '# Original';
      bodyFormat = 'md';
      translationId = 1;
      translation() { return {fields: {body: '<h1>Traduit</h1>'}}; }
    }
    const wrapper = mount(FormattedText, {props: {model: new Comment(), field: 'body'},
      global: {directives: {marked}, plugins: [createI18n({legacy: false})]}});
    wrappers.push(wrapper);
    expect(wrapper.find('h1').text()).toBe('Traduit');
    expect(wrapper.attributes('data-content-model')).toBe('comment-7');
    expect(wrapper.attributes('data-content-field')).toBe('body');
  });
});
