import { describe, expect, it } from 'vitest';
import { computed, reactive, toRaw } from 'vue';
import Database, { collectionOf } from '@/shared/record_store/db';

function collection(indices = ['topicId']) {
  const items = new Database().addCollection('items', {indices});
  items.ensureUniqueIndex('id');
  return items;
}

const ids = docs => docs.map(doc => doc.id);

describe('record store database', () => {
  it('orders position keys as strings in sorts and ranges', () => {
    const items = collection();
    ['00002', '00001-00002', '00010', '00001', '00001-00001'].forEach((positionKey, i) => {
      items.insert({id: i + 1, topicId: 1, positionKey});
    });

    const keys = docs => docs.map(doc => doc.positionKey);
    expect(keys(items.chain().simplesort('positionKey').data()))
      .toEqual(['00001', '00001-00001', '00001-00002', '00002', '00010']);
    expect(keys(items.chain().simplesort('positionKey', true).data()))
      .toEqual(['00010', '00002', '00001-00002', '00001-00001', '00001']);
    expect(keys(items.chain().find({topicId: 1, positionKey: {$gt: '00001-00001'}}).simplesort('positionKey').data()))
      .toEqual(['00001-00002', '00002', '00010']);
    expect(keys(items.chain().find({positionKey: {$lte: '00001-00002'}}).simplesort('positionKey').data()))
      .toEqual(['00001', '00001-00001', '00001-00002']);
  });

  it('sorts null and undefined first and dates by time', () => {
    const items = collection();
    items.insert({id: 1, at: new Date('2025-03-01')});
    items.insert({id: 2, at: null});
    items.insert({id: 3, at: new Date('2025-01-01')});
    items.insert({id: 4});

    expect(ids(items.chain().simplesort('at').data())).toEqual([2, 4, 3, 1]);
    expect(ids(items.chain().simplesort('at', true).data())).toEqual([1, 3, 2, 4]);
    expect(ids(items.find({at: {$gt: new Date('2025-02-01')}}))).toEqual([1]);
    expect(ids(items.find({at: {$between: [new Date('2024-12-01'), new Date('2025-02-01')]}}))).toEqual([3]);
  });

  it('looks up unique fields by value and follows changed ids', () => {
    const items = collection();
    const draft = items.insert(reactive({id: null, topicId: 1}));
    expect(items.by('id', null)).toBeUndefined();

    draft.id = 7;
    items.update(draft);
    expect(items.by('id', 7)).toBe(draft);
    expect(items.by('id', '7')).toBe(draft);

    expect(() => items.insert({id: 7})).toThrow('Duplicate key for property id: 7');
    const other = items.insert({id: 8});
    other.id = 7;
    expect(() => items.update(other)).toThrow('Duplicate key for property id: 7');
  });

  it('finds documents by their indexed values after an update, in collection order', () => {
    const items = collection();
    const first = items.insert({id: 1, topicId: 1});
    items.insert({id: 2, topicId: 2});
    items.insert({id: 3, topicId: 1});

    first.topicId = 2;
    items.update(first);

    expect(ids(items.find({topicId: 1}))).toEqual([3]);
    expect(ids(items.find({topicId: 2}))).toEqual([1, 2]);
    expect(ids(items.find({topicId: {$in: [1, 2, 2]}}))).toEqual([1, 2, 3]);
    expect(ids(items.find({$and: [{topicId: 2}, {id: {$ne: 2}}]}))).toEqual([1]);
  });

  it('removes documents from data, lookups and queries', () => {
    const items = collection();
    const doc = items.insert({id: 1, topicId: 1});
    items.insert({id: 2, topicId: 1});

    items.remove(doc);

    expect(ids(items.data)).toEqual([2]);
    expect(items.by('id', 1)).toBeUndefined();
    expect(ids(items.find({topicId: 1}))).toEqual([2]);
    expect(collectionOf(doc)).toBeUndefined();
    expect(() => items.remove(doc)).toThrow('Document is not in items');
    items.insert(doc);
    expect(ids(items.find({topicId: 1}))).toEqual([2, 1]);
  });

  it('tracks membership for a reactive record and its raw object without adding properties', () => {
    const items = collection();
    const record = reactive({id: 1, topicId: 1});
    items.insert(record);

    expect(collectionOf(record)).toBe(items);
    expect(collectionOf(toRaw(record))).toBe(items);
    expect(Object.keys(toRaw(record))).toEqual(['id', 'topicId']);
    expect(() => new Database().addCollection('others').insert(record)).toThrow('Document is already in items');
  });

  it('returns result arrays the caller can change without changing the collection', () => {
    const items = collection();
    items.insert({id: 1});
    items.chain().data().push({id: 2});
    items.chain().simplesort('id', true).data();
    expect(ids(items.data)).toEqual([1]);
  });

  it('evaluates the query operators used by the app', () => {
    const items = collection();
    items.insert({id: 1, name: 'Ana Lee', tagIds: [1, 2], closedAt: null});
    items.insert({id: 2, name: 'Bo Ana', tagIds: [2], closedAt: new Date('2025-01-01')});
    items.insert({id: 3, name: null, tagIds: [], closedAt: new Date('2025-06-01')});

    expect(ids(items.find({tagIds: {$contains: 2}}))).toEqual([1, 2]);
    expect(ids(items.find({tagIds: {$contains: [1, 2]}}))).toEqual([1]);
    expect(ids(items.find({name: {$regex: ['^ana', 'i']}}))).toEqual([1]);
    expect(ids(items.find({name: {$regex: / ana/i}}))).toEqual([2]);
    expect(ids(items.find({id: {$nin: [1, 3]}}))).toEqual([2]);
    expect(ids(items.find({$or: [{closedAt: null}, {closedAt: {$gt: new Date('2025-03-01')}}]}))).toEqual([1, 3]);
    expect(ids(items.chain().find({}).where(doc => doc.id > 1).limit(1).data())).toEqual([2]);
    expect(items.chain().find({closedAt: {$ne: null}}).count()).toBe(2);
    expect(items.findOne({id: 9})).toBeNull();
  });

  it('rejects query conditions it does not understand', () => {
    const items = collection();
    items.insert({id: 1});
    expect(() => items.find({id: {$jgt: 0}})).toThrow('Unsupported query operator $jgt on id');
    expect(() => items.find({id: {$gt: 0, $lt: 5}})).toThrow('Query conditions take one operator');
  });

  describe('reactivity', () => {
    // Count how often a computed query evaluates, reading it after each change.
    function counted(query) {
      let runs = 0;
      const result = computed(() => { runs++; return query(); });
      return {value: () => result.value, runs: () => runs};
    }

    it('re-runs a unique lookup when that value is inserted, and not for other values', () => {
      const items = collection();
      const lookup = counted(() => items.by('id', 2));
      expect(lookup.value()).toBeUndefined();
      items.insert(reactive({id: 1, topicId: 1}));
      expect(lookup.value()).toBeUndefined();
      expect(lookup.runs()).toBe(1);
      items.insert(reactive({id: 2, topicId: 1}));
      expect(lookup.value().id).toBe(2);
      expect(lookup.runs()).toBe(2);
    });

    it('re-runs an indexed query only when a document enters or leaves its sets', () => {
      const items = collection();
      const first = reactive({id: 1, topicId: 1});
      items.insert(first);
      const query = counted(() => ids(items.find({topicId: 1})));
      expect(query.value()).toEqual([1]);

      items.insert(reactive({id: 2, topicId: 2}));
      expect(query.value()).toEqual([1]);
      expect(query.runs()).toBe(1);

      const third = reactive({id: 3, topicId: 2});
      items.insert(third);
      third.topicId = 1;
      items.update(third);
      expect(query.value()).toEqual([1, 3]);

      first.topicId = 2;
      items.update(first);
      expect(query.value()).toEqual([3]);

      items.remove(third);
      expect(query.value()).toEqual([]);
    });

    it('re-runs a scan on insert and remove, and when a document it read changes', () => {
      const items = collection();
      const first = reactive({id: 1, topicId: 1, title: 'b'});
      items.insert(first);
      const query = counted(() => items.chain().find({title: {$regex: '^b'}}).data().map(doc => doc.title));
      expect(query.value()).toEqual(['b']);
      items.insert(reactive({id: 2, topicId: 1, title: 'bb'}));
      expect(query.value()).toEqual(['b', 'bb']);
      first.title = 'a';
      expect(query.value()).toEqual(['bb']);
      expect(query.runs()).toBe(3);
    });

    it('does not subscribe a computed that inserts documents to its own writes', () => {
      const items = collection();
      const created = counted(() => items.insert(reactive({id: 1, topicId: 1})).id);
      expect(created.value()).toBe(1);
      expect(created.value()).toBe(1);
      expect(created.runs()).toBe(1);
    });
  });
});
