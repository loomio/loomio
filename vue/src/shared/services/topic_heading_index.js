import { marked } from 'marked';
import { customRenderer, options } from '@/shared/helpers/marked';
import Records from '@/shared/services/records';

const contentFields = {
  Discussion: {collection: 'discussions', model_type: 'discussion', field: 'description'},
  Poll: {collection: 'polls', model_type: 'poll', field: 'details'},
  Comment: {collection: 'comments', model_type: 'comment', field: 'body'},
  Stance: {collection: 'stances', model_type: 'stance', field: 'reason'},
  Outcome: {collection: 'outcomes', model_type: 'outcome', field: 'statement'}
};
const contentKinds = new Set(['new_discussion', 'poll_created', 'new_comment', 'stance_created', 'stance_updated', 'outcome_created']);
const collections = Object.fromEntries(Object.values(contentFields).map(value => [value.model_type, value.collection]));

export function scrapeHeadings(text, format) {
  // A template is inert: extracting labels must not load images or embeds from
  // the content. Use the same Markdown renderer as formatted-text.
  const template = document.createElement('template');
  template.innerHTML = format === 'md' ? marked(text || '', {...options, renderer: customRenderer()}) : text || '';
  return [...template.content.querySelectorAll('h1,h2,h3,h4,h5,h6')].flatMap((node, index) => {
    const title = node.textContent.replace(/\s+/g, ' ').trim();
    return title ? [{title, level: Number(node.tagName[1]), index}] : [];
  });
}

// Seed unloaded sections once from the server. Subsequent record-store updates
// only replace changed content locally; unrelated traffic never fetches the
// outline or reparses unchanged text. Empty sections retain their jump metadata
// so the first heading added to an unloaded contribution can appear too.
export default class TopicHeadingIndex {
  constructor(topicId, records = Records) {
    this.topicId = topicId;
    this.records = records;
    this.sections = new Map();
    this.sources = new Map();
    this.initialHeadings = new Map();
    this.loadedRecords = new Set();
    this.loadedItems = new Set();
    this.headings = [];
  }

  seed(sections) {
    sections.forEach(section => {
      this.initialHeadings.set(section.topic_item_id, section.headings);
      const current = this.sections.get(section.topic_item_id);
      this.sections.set(section.topic_item_id, {...section, ...current, headings: section.headings});
    });
    this.sources.clear();
    return this.update(true);
  }

  update(changed = false) {
    const items = this.records.topicItems.find({topicId: this.topicId}).filter(item => !item.deleted && contentKinds.has(item.kind));
    const loadedItems = new Set(items.map(item => item.id));
    for (const id of this.loadedItems) {
      if (!loadedItems.has(id)) {
        this.sections.delete(id);
        this.sources.delete(id);
        this.initialHeadings.delete(id);
        this.loadedRecords.delete(id);
        changed = true;
      }
    }
    this.loadedItems = loadedItems;

    for (const item of items) {
      const fields = contentFields[item.itemableType];
      const previous = this.sections.get(item.id);
      if (!previous || previous.position_key !== item.positionKey) { changed = true; }
      this.sections.set(item.id, {...previous, topic_item_id: item.id, sequence_id: item.sequenceId,
        position_key: item.positionKey, field: fields.field, model_type: fields.model_type,
        model_id: item.itemableId, headings: previous?.headings || []});
    }

    const removedPolls = new Set([...this.sections.values()]
      .filter(section => {
        if (section.model_type !== 'poll') { return false; }
        const poll = this.record(section);
        return poll && (poll.discardedAt || poll.topicId !== this.topicId);
      })
      .map(section => section.position_key));

    for (const section of this.sections.values()) {
      const record = this.record(section);
      const pollId = record?.pollId || section.poll_id;
      const poll = pollId ? this.records.polls.find(pollId) : null;
      const ancestors = section.position_key.split('-').map((part, index, parts) => parts.slice(0, index + 1).join('-'));
      let visible = !record?.discardedAt && (!record?.topicId || record.topicId === this.topicId) && !poll?.discardedAt && !ancestors.some(key => removedPolls.has(key));
      if (section.model_type === 'stance') {
        visible &&= !record?.revokedAt && !record?.redactedAt && (!record || !!record.castAt);
        visible &&= poll ? !poll.anonymous && !!poll.showResults() : !record;
      }
      const translation = record?.translationId ? this.records.translations.find(record.translationId) : null;
      const text = translation ? translation.fields[section.field] : record?.[section.field];
      const format = translation ? 'html' : record?.[`${section.field}Format`];
      const source = this.sources.get(section.topic_item_id);
      if (source && source.text === text && source.format === format && source.visible === visible && source.record === record) { continue; }

      // Missing records can be unloaded server sections, or records that were
      // removed locally. Preserve only the former's initial outline.
      if (record) { this.loadedRecords.add(section.topic_item_id); }
      if (!visible || (!record && this.loadedRecords.has(section.topic_item_id))) {
        section.headings = [];
      } else if (record) {
        section.headings = scrapeHeadings(text, format);
      } else {
        section.headings = this.initialHeadings.get(section.topic_item_id) || [];
      }
      this.sources.set(section.topic_item_id, {text, format, visible, record});
      changed = true;
    }

    if (changed) {
      this.headings = [...this.sections.values()]
        .sort((a, b) => a.position_key.localeCompare(b.position_key) || a.topic_item_id - b.topic_item_id)
        .flatMap(({headings, ...section}) => headings.map(heading => ({...section, ...heading})));
    }
    return this.headings;
  }

  record(section) {
    return this.records[collections[section.model_type]].find(section.model_id);
  }
}
