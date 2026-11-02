import { nextTick } from 'vue';
import Records from '@/shared/services/records';
import ScrollService from '@/shared/services/scroll_service';
import EventBus from '@/shared/services/event_bus';

export default new class TopicHeadingsService {
  async fetch(topicId, cancelled = () => false) {
    const sections = [];
    let offset = 0;
    do {
      const data = await Records.remote.get('topic_items/headings', {topic_id: topicId, limit: 200, offset});
      if (cancelled()) { return []; }
      sections.push(...data.sections);
      offset = data.meta.next_offset;
    } while (offset !== null);
    return sections;
  }

  // Load the containing contribution and expand its display ancestry before
  // resolving the server's heading position within that field. Labels never
  // become selectors, so duplicate titles and non-Latin headings work alike.
  async jumpTo(heading, loader, cancelled = () => false) {
    loader.addLoadSequenceIdRule(heading.sequence_id);
    await loader.fetch();
    if (cancelled()) { return; }
    loader.updateCollection();
    for (let item = Records.topicItems.find(heading.topic_item_id); item; item = item.parent()) {
      loader.expand(item);
    }
    await nextTick();
    const root = document.querySelector(`.sequenceId-${heading.sequence_id} [data-content-model="${heading.model_type}-${heading.model_id}"][data-content-field="${heading.field}"]`);
    const target = root?.querySelectorAll('h1,h2,h3,h4,h5,h6')[heading.index];
    if (!target) { return; }
    const key = `${heading.topic_item_id}-${heading.field}-${heading.index}`;
    target.setAttribute('data-content-heading', key);
    target.setAttribute('tabindex', '-1');
    target.focus({preventScroll: true});
    const selector = `[data-content-heading="${key}"]`;
    EventBus.$emit('setAnchor', selector, 72);
    return ScrollService.scrollToSettled(selector);
  }
};
