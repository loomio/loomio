// In-memory record collections for the client record store.
//
// This is Loomio's replacement for LokiJS. It keeps the part of Loki's API the
// app uses, so query code reads the same, and drops the rest (dynamic views,
// persistence, transforms, joins, binary indices, change tracking).
//
// SETUP
//
//   const db = new Database();
//   const polls = db.addCollection('polls', {indices: ['groupId', 'topicId']});
//   polls.ensureUniqueIndex('id');
//
// Each records interface does this from its model's static `indices` and
// `uniqueIndices` (see base_records_interface.js). addCollection returns the
// existing collection when the name is already in use.
//
// COLLECTIONS
//
//   collection.data              every document, in insertion order (read only)
//   collection.insert(doc)       add a document; returns it
//   collection.update(doc)       re-index a document after changing its fields
//   collection.remove(doc)       remove a document
//   collection.by(field, value)  document with that unique value, or undefined
//   collection.find(query)       array of matching documents
//   collection.findOne(query)    first matching document, or null
//   collection.chain()           a result set for filtering and sorting
//   collectionOf(doc)            the collection holding doc, or undefined
//
// Documents are stored as given (usually reactive model proxies), never copied.
// Membership is kept in a module-level WeakMap keyed by the raw document, so
// no properties are added to documents and Vue never tracks the bookkeeping.
// A document is in at most one collection. Inserting it twice, or updating or
// removing a document that is not in the collection, throws.
//
// Indices change only through insert, update and remove. Code that changes an
// indexed field of a stored document must call collection.update(doc);
// BaseModel#update does this for imported records.
//
// REACTIVITY
//
// Reads are tracked by Vue, so a query inside computed(), a template or a
// watcher re-runs when the documents it could return change:
//
//   by(field, value)       tracks that one value of the unique index
//   indexed find()         tracks the index sets it started from
//   scans and data         track membership (any insert or remove)
//
// insert, remove and update trigger only what they change: membership, the
// unique values and the index sets a document enters or leaves. Field values
// are tracked by the reactive documents themselves, so a query that filters or
// sorts by an unindexed field re-runs when a document it read changes that
// field. has() and collectionOf() are not tracked.
//
// RESULT SETS
//
//   collection.chain()
//     .find(query)                  keep matching documents (repeatable)
//     .where(doc => boolean)        keep documents passing a function
//     .simplesort(field, desc)      sort by one field; desc is a boolean or {desc}
//     .sort((a, b) => number)       sort with a comparator
//     .limit(count)                 keep the first count documents
//     .count()                      number of documents
//     .data()                       array of documents
//
// A chain starts with every document in collection order. Sorts are stable, so
// documents with equal values keep their previous relative order. data()
// returns an array the caller may change.
//
// QUERIES
//
//   {field: value}                  equal (===); value may be null or a Date object
//   {field: {$eq: value}}           equal (===)
//   {field: {$ne: value}}           not equal (!==)
//   {field: {$gt|$gte|$lt|$lte: v}} ordered comparison (see ORDERING)
//   {field: {$between: [low, high]}} low <= value <= high; null never matches
//   {field: {$in: [values]}}        equal to one of the values
//   {field: {$nin: [values]}}       equal to none of the values
//   {field: {$regex: pattern}}      RegExp, string, or [pattern, flags]
//   {field: {$contains: v}}         array or string field includes v; an array v
//                                   must be included entirely
//   {$and: [queries]}, {$or: [queries]}
//
// Several keys in one query object must all match. A field condition takes
// exactly one operator, and an unknown operator throws, so a typo cannot
// silently match nothing. Fields are top-level properties; there is no dot
// notation. Equality with a Date object compares identity, as with Loki, so
// use $gte/$lte or $between for dates.
//
// ORDERING
//
// Sorts and range operators use one order: null and undefined first, then
// booleans, numbers, strings, and other values. Dates compare by time. Strings
// compare as JavaScript strings. Loki compared numeric-looking strings as
// numbers, which put "00002" before "00001-00001" and broke position-key ranges
// and sorts; that needed the $jgt/$jlt operators and hand-written comparators.
//
// INDICES
//
// Unique indices map String(value) to one document, so by('id', 7) and
// by('id', '7') find the same record. Null and undefined values are not
// indexed. Inserting or updating to a value another document holds throws.
//
// Other indices map each value to the set of documents holding it. When a
// chain's first find() requires indexed fields to equal values ({field: value},
// $eq or $in, at the top level or inside $and), it starts from the smallest of
// those sets instead of scanning every document, then checks each candidate
// against the whole query. Results stay in collection order. Range filters,
// $or, where() and sorts scan the documents they are given. Index the fields
// queries commonly start from, such as foreign keys.
//
// EXTENDING
//
// Add an operator to `operators` below when a query needs one; it receives the
// query value and returns a test for a field value. If client-side persistence
// is needed later, each collection's state is its `data` array plus its index
// definitions: saving can serialise `data`, and loading can insert the
// documents into fresh collections so the indices are rebuilt.

import { shallowReactive, shallowRef, toRaw } from 'vue';

// raw doc -> {collection, doc, sequence, uniqueValues, hashValues}
const entries = new WeakMap();

export function collectionOf(doc) {
  const entry = entries.get(toRaw(doc));
  return entry && entry.collection;
}

const typeRanks = {undefined: 0, boolean: 1, number: 2, string: 3};

function typeRank(value) {
  if (value === null || value === undefined) { return 0; }
  return typeRanks[typeof value] ?? 4;
}

// Total order used by sorts and range operators: null and undefined first,
// then booleans, numbers, strings and other values. Dates compare by time.
export function compareValues(a, b) {
  if (a instanceof Date) { a = a.getTime(); }
  if (b instanceof Date) { b = b.getTime(); }
  const rankA = typeRank(a);
  const rankB = typeRank(b);
  if (rankA !== rankB) { return rankA < rankB ? -1 : 1; }
  if (rankA === 0) { return 0; }
  if (a < b) { return -1; }
  if (a > b) { return 1; }
  return 0;
}

function containsCheck(container) {
  if (typeof container === 'string' || Array.isArray(container)) {
    return item => container.indexOf(item) !== -1;
  }
  if (typeof container === 'object' && container !== null) {
    return item => Object.prototype.hasOwnProperty.call(container, item);
  }
  return null;
}

function compileRegex(value) {
  if (value instanceof RegExp) { return value; }
  if (Array.isArray(value)) { return new RegExp(value[0], value[1]); }
  return new RegExp(value);
}

const operators = {
  $eq:  b => a => a === b,
  $ne:  b => a => a !== b,
  $gt:  b => a => compareValues(a, b) > 0,
  $gte: b => a => compareValues(a, b) >= 0,
  $lt:  b => a => compareValues(a, b) < 0,
  $lte: b => a => compareValues(a, b) <= 0,
  $between: ([low, high]) => a =>
    a !== null && a !== undefined && compareValues(a, low) >= 0 && compareValues(a, high) <= 0,
  $in:  b => { const set = new Set(b); return a => set.has(a); },
  $nin: b => { const set = new Set(b); return a => !set.has(a); },
  $regex: b => { const regex = compileRegex(b); return a => regex.test(a); },
  $contains: b => a => {
    const check = containsCheck(a);
    if (check === null) { return false; }
    return Array.isArray(b) ? b.every(check) : check(b);
  },
};

// A field condition is either a plain value (equality) or {$operator: value}.
// Dates and null are plain values.
function fieldCondition(condition) {
  if (condition === null || typeof condition !== 'object' || condition instanceof Date) {
    return ['$eq', condition];
  }
  const operatorNames = Object.keys(condition);
  if (operatorNames.length !== 1) {
    throw new Error(`Query conditions take one operator, got: ${operatorNames.join(', ')}`);
  }
  return [operatorNames[0], condition[operatorNames[0]]];
}

// Compile a query object to a predicate, or null when it matches everything.
// Several keys in one object are combined with AND.
export function compileQuery(query) {
  if (!query) { return null; }
  const predicates = Object.keys(query).map(key => {
    if (key === '$and' || key === '$or') {
      const parts = query[key].map(part => compileQuery(part) || (() => true));
      return key === '$and'
        ? doc => parts.every(part => part(doc))
        : doc => parts.some(part => part(doc));
    }
    const [operator, value] = fieldCondition(query[key]);
    if (!operators[operator]) {
      throw new Error(`Unsupported query operator ${operator} on ${key}`);
    }
    const test = operators[operator](value);
    return doc => test(doc[key]);
  });
  if (predicates.length === 0) { return null; }
  if (predicates.length === 1) { return predicates[0]; }
  return doc => predicates.every(predicate => predicate(doc));
}

// Collect the conditions in a query that require an indexed field to equal a
// value, as [field, values] pairs. Looks at top-level keys and, recursively,
// the items of a top-level $and.
function indexedEqualities(query, indices, found = []) {
  if (!query) { return found; }
  Object.keys(query).forEach(key => {
    if (key === '$and') {
      query.$and.forEach(part => indexedEqualities(part, indices, found));
    } else if (indices.has(key)) {
      const [operator, value] = fieldCondition(query[key]);
      if (operator === '$eq') { found.push([key, [value]]); }
      if (operator === '$in') { found.push([key, value]); }
    }
  });
  return found;
}

class Resultset {
  constructor(collection) {
    this.collection = collection;
    this.rows = null; // null means "every document", in collection order
  }

  docs() {
    return this.rows === null ? this.collection.data : this.rows;
  }

  find(query) {
    const predicate = compileQuery(query);
    if (predicate === null) { return this; }
    const candidates = this.rows === null ? this.collection.candidates(query) : this.rows;
    this.rows = candidates.filter(predicate);
    return this;
  }

  where(test) {
    this.rows = this.docs().filter(test);
    return this;
  }

  simplesort(field, options) {
    const desc = options === true || !!(options && options.desc);
    const direction = desc ? -1 : 1;
    return this.sort((a, b) => direction * compareValues(a[field], b[field]));
  }

  sort(compare) {
    this.rows = this.docs().slice().sort(compare);
    return this;
  }

  limit(count) {
    this.rows = this.docs().slice(0, count);
    return this;
  }

  count() {
    return this.docs().length;
  }

  data() {
    return this.rows === null ? this.collection.data.slice() : this.rows;
  }
}

class Collection {
  constructor(name, {indices = []} = {}) {
    this.name = name;
    this.documents = [];
    this.membershipChanges = 0;
    this.membership = shallowRef(0); // set on insert and remove; never read while writing
    this.nextSequence = 0;
    // Index maps and sets are shallowReactive so Vue tracks each key. Internal
    // reads go through toRaw so imports inside an effect do not subscribe it.
    this.uniqueIndices = new Map(); // field -> Map(String(value) -> doc)
    this.hashIndices = new Map();   // field -> Map(value -> Set(entry))
    indices.forEach(field => this.ensureIndex(field));
  }

  // Every document, in insertion order. Do not change the array.
  get data() {
    this.membership.value;
    return this.documents;
  }

  ensureUniqueIndex(field) {
    if (this.uniqueIndices.has(field)) { return; }
    this.uniqueIndices.set(field, shallowReactive(new Map()));
    this.documents.forEach(doc => this.addUnique(field, this.entry(doc)));
  }

  ensureIndex(field) {
    if (this.hashIndices.has(field)) { return; }
    this.hashIndices.set(field, shallowReactive(new Map()));
    this.documents.forEach(doc => this.addHashed(field, this.entry(doc), doc[field]));
  }

  hasUniqueIndex(field) {
    return this.uniqueIndices.has(field);
  }

  has(doc) {
    return this.entry(doc) !== undefined;
  }

  insert(doc) {
    const current = collectionOf(doc);
    if (current) { throw new Error(`Document is already in ${current.name}`); }
    const entry = {collection: this, doc, sequence: this.nextSequence++, uniqueValues: {}, hashValues: {}};
    this.uniqueIndices.forEach((index, field) => this.checkUnique(field, entry, doc[field]));
    entries.set(toRaw(doc), entry);
    this.uniqueIndices.forEach((index, field) => this.addUnique(field, entry));
    this.hashIndices.forEach((index, field) => this.addHashed(field, entry, doc[field]));
    this.documents.push(doc);
    this.membership.value = ++this.membershipChanges;
    return doc;
  }

  // Re-index a document after its fields have changed.
  update(doc) {
    const entry = this.requireEntry(doc);
    this.uniqueIndices.forEach((index, field) => {
      const value = entry.doc[field];
      if (value === entry.uniqueValues[field]) { return; }
      this.checkUnique(field, entry, value);
      this.removeUnique(field, entry);
      this.addUnique(field, entry);
    });
    this.hashIndices.forEach((index, field) => {
      const value = entry.doc[field];
      if (value === entry.hashValues[field]) { return; }
      this.removeHashed(field, entry);
      this.addHashed(field, entry, value);
    });
    return entry.doc;
  }

  remove(doc) {
    const entry = this.requireEntry(doc);
    this.uniqueIndices.forEach((index, field) => this.removeUnique(field, entry));
    this.hashIndices.forEach((index, field) => this.removeHashed(field, entry));
    this.documents.splice(this.documents.indexOf(entry.doc), 1);
    entries.delete(toRaw(entry.doc));
    this.membership.value = ++this.membershipChanges;
    return entry.doc;
  }

  by(field, value) {
    const index = this.uniqueIndices.get(field);
    if (!index) { throw new Error(`${this.name} has no unique index on ${field}`); }
    if (value === null || value === undefined) { return undefined; }
    return index.get(String(value)); // tracked
  }

  chain() {
    return new Resultset(this);
  }

  find(query) {
    return this.chain().find(query).data();
  }

  findOne(query) {
    return this.find(query)[0] ?? null;
  }

  // Documents that may match a query, in collection order. When the query
  // requires indexed fields to equal values, start from the smallest set of
  // documents any one of those indices gives.
  candidates(query) {
    let smallest = null;
    indexedEqualities(query, this.hashIndices).forEach(([field, values]) => {
      const index = this.hashIndices.get(field);
      const sets = [...new Set(values)].map(value => index.get(value)).filter(Boolean);
      const size = sets.reduce((total, entries) => total + entries.size, 0);
      if (smallest === null || size < smallest.size) { smallest = {sets, size}; }
    });
    if (smallest === null) { return this.data; } // tracks membership
    // Sets keep insertion order, which only departs from collection order
    // after an indexed field changes or when several sets are combined.
    const found = [];
    smallest.sets.forEach(entries => entries.forEach(entry => found.push(entry)));
    let ordered = true;
    for (let i = 1; i < found.length && ordered; i++) { ordered = found[i - 1].sequence < found[i].sequence; }
    if (!ordered) { found.sort((a, b) => a.sequence - b.sequence); }
    return found.map(entry => entry.doc);
  }

  entry(doc) {
    const entry = entries.get(toRaw(doc));
    return entry && entry.collection === this ? entry : undefined;
  }

  requireEntry(doc) {
    const entry = this.entry(doc);
    if (!entry) { throw new Error(`Document is not in ${this.name}`); }
    return entry;
  }

  checkUnique(field, entry, value) {
    if (value === null || value === undefined) { return; }
    const existing = toRaw(this.uniqueIndices.get(field)).get(String(value));
    if (existing && existing !== entry.doc) {
      throw new Error(`Duplicate key for property ${field}: ${value}`);
    }
  }

  addUnique(field, entry) {
    const value = entry.doc[field];
    entry.uniqueValues[field] = value;
    if (value === null || value === undefined) { return; }
    this.uniqueIndices.get(field).set(String(value), entry.doc);
  }

  removeUnique(field, entry) {
    const value = entry.uniqueValues[field];
    if (value === null || value === undefined) { return; }
    this.uniqueIndices.get(field).delete(String(value));
  }

  addHashed(field, entry, value) {
    entry.hashValues[field] = value;
    const index = this.hashIndices.get(field);
    const docs = toRaw(index).get(value);
    if (docs) {
      docs.add(entry);
    } else {
      index.set(value, shallowReactive(new Set([entry])));
    }
  }

  removeHashed(field, entry) {
    const index = this.hashIndices.get(field);
    const value = entry.hashValues[field];
    const docs = toRaw(index).get(value);
    docs.delete(entry);
    if (toRaw(docs).size === 0) { index.delete(value); }
  }
}

export default class Database {
  constructor() {
    this.collections = new Map();
  }

  addCollection(name, options) {
    if (!this.collections.has(name)) {
      this.collections.set(name, new Collection(name, options));
    }
    return this.collections.get(name);
  }
}
