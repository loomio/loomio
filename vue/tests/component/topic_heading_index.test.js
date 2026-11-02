import { beforeEach, describe, expect, it, vi } from 'vitest';
import Loki from 'lokijs';
import TopicHeadingIndex, { scrapeHeadings } from '@/shared/services/topic_heading_index';

vi.mock('@/shared/services/records', () => ({default: {}}));

let records;
let index;
beforeEach(() => {
  const db = new Loki('heading-index');
  records = Object.fromEntries(['topicItems', 'discussions', 'polls', 'comments', 'stances', 'outcomes', 'translations'].map(name => {
    const collection = db.addCollection(name);
    return [name, {collection, find: query => typeof query === 'number' ? collection.findOne({id: query}) : collection.find(query)}];
  }));
  index = new TopicHeadingIndex(9, records);
});

const heading = title => ({title, level: 2, index: 0});
const section = (id, title, overrides = {}) => ({topic_item_id: id, sequence_id: id, position_key: `00000-${String(id).padStart(5, '0')}`,
  model_type: 'comment', model_id: id, field: 'body', poll_id: null, headings: title ? [heading(title)] : [], ...overrides});
const titles = () => index.headings.map(heading => heading.title);
function comment(id, body, bodyFormat = 'html') {
  return records.comments.collection.insert({id, topicId: 9, body, bodyFormat});
}
function item(id, overrides = {}) {
  return records.topicItems.collection.insert({id, topicId: 9, sequenceId: id, positionKey: section(id).position_key,
    itemableType: 'Comment', itemableId: id, kind: 'new_comment', ...overrides});
}

describe('incremental thread heading index', () => {
  it('scrapes HTML and Markdown with the display renderer, preserving blank-heading positions and duplicate labels', () => {
    expect(scrapeHeadings('<h2></h2><h2>Agenda &amp; <em>notes</em></h2><h3>Agenda</h3>', 'html')).toEqual([
      {title: 'Agenda & notes', level: 2, index: 1}, {title: 'Agenda', level: 3, index: 2}
    ]);
    expect(scrapeHeadings('# 日本語\n\n### Nested\n\n```\n# Code\n```', 'md')).toEqual([
      {title: '日本語', level: 1, index: 0}, {title: 'Nested', level: 3, index: 1}
    ]);
  });

  it('replaces added, renamed and removed headings locally while retaining unloaded sections', () => {
    index.seed([section(1, 'Old'), section(2, 'Unloaded')]);
    const record = comment(1, '## Renamed\n\n### Added', 'md');
    index.update();
    expect(titles()).toEqual(['Renamed', 'Added', 'Unloaded']);
    record.body = 'No headings now';
    index.update();
    expect(titles()).toEqual(['Unloaded']);
  });

  it('can add the first heading to an unloaded item using the initial empty section metadata', () => {
    index.seed([section(1, ''), section(2, 'Later')]);
    comment(1, '<h2>First heading</h2>');
    index.update();
    expect(titles()).toEqual(['First heading', 'Later']);
    expect(index.headings[0]).toMatchObject({topic_item_id: 1, sequence_id: 1, model_id: 1, field: 'body'});
  });

  it('only reparses changed content and leaves unrelated traffic out of the outline', () => {
    const first = comment(1, '<h2>First</h2>');
    comment(2, '<h2>Second</h2>');
    index.seed([section(1, 'First'), section(2, 'Second')]);
    const original = index.headings;
    const createElement = vi.spyOn(document, 'createElement');
    comment(3, '<h2>Other thread</h2>').topicId = 99;
    index.update();
    first.attachments = [];
    index.update();
    expect(index.headings).toBe(original);
    expect(createElement).not.toHaveBeenCalled();
    first.body = '<h2>Changed</h2>';
    index.update();
    expect(createElement).toHaveBeenCalledExactlyOnceWith('template');
    expect(titles()).toEqual(['Changed', 'Second']);
    createElement.mockRestore();
  });

  it('handles new contributions, reordering, removal and movement to another thread', () => {
    const firstItem = item(1);
    const first = comment(1, '<h2>First</h2>');
    item(2);
    comment(2, '<h2>Second</h2>');
    index.update();
    expect(titles()).toEqual(['First', 'Second']);
    firstItem.positionKey = '00000-00003';
    index.update();
    expect(titles()).toEqual(['Second', 'First']);
    first.topicId = 99;
    index.update();
    expect(titles()).toEqual(['Second']);
    records.topicItems.collection.remove(records.topicItems.find(2));
    index.update();
    expect(titles()).toEqual([]);
  });

  it('does not let a slow initial request overwrite edits already received locally', () => {
    item(1);
    comment(1, '<h2>Latest edit</h2>');
    index.update();
    index.seed([section(1, 'Stale response'), section(2, 'Unloaded')]);
    expect(titles()).toEqual(['Latest edit', 'Unloaded']);
  });

  it('uses updated translation records without refetching the outline', () => {
    const record = comment(1, '<h2>Original</h2>');
    index.seed([section(1, 'Original')]);
    record.translationId = 8;
    const translation = records.translations.collection.insert({id: 8, fields: {body: '<h2>Traduit</h2>'}});
    index.update();
    expect(titles()).toEqual(['Traduit']);
    translation.fields.body = '<h2>Traduction modifiée</h2>';
    index.update();
    expect(titles()).toEqual(['Traduction modifiée']);
  });

  it('clears removed content, including unloaded descendants of a removed poll, and can restore it', () => {
    const poll = records.polls.collection.insert({id: 5, topicId: 9, details: '<h2>Poll</h2>', detailsFormat: 'html'});
    index.seed([section(5, 'Poll', {model_type: 'poll', field: 'details'}), section(6, 'Unloaded reply', {position_key: '00000-00005-00001'})]);
    expect(titles()).toEqual(['Poll', 'Unloaded reply']);
    poll.discardedAt = new Date();
    index.update();
    expect(titles()).toEqual([]);
    poll.discardedAt = null;
    index.update();
    expect(titles()).toEqual(['Poll', 'Unloaded reply']);
  });

  it('respects changing poll visibility, redaction and anonymity even with cached vote reasons', () => {
    let showResults = false;
    const poll = records.polls.collection.insert({id: 5, topicId: 9, anonymous: false, showResults: () => showResults});
    const stance = records.stances.collection.insert({id: 1, pollId: 5, castAt: new Date(), reason: '<h2>Private reason</h2>', reasonFormat: 'html'});
    index.seed([section(1, '', {model_type: 'stance', field: 'reason', poll_id: 5})]);
    expect(titles()).toEqual([]);
    showResults = true;
    index.update();
    expect(titles()).toEqual(['Private reason']);
    stance.redactedAt = new Date();
    index.update();
    expect(titles()).toEqual([]);
    stance.redactedAt = null;
    poll.anonymous = true;
    index.update();
    expect(titles()).toEqual([]);
  });
});
