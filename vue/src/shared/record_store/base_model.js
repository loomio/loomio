import utils from './utils';
import { camelCase, compact, each, isArray, isEqual, snakeCase, defaults, orderBy, assign, includes } from 'lodash-es';

import Records from '@/shared/services/records';
import { reactive, toRaw } from 'vue';
import { collectionOf } from '@/shared/record_store/db';

// Equal for import purposes: same primitive, or same contents for dates,
// arrays and plain objects.
function sameValue(current, value) {
  if (Object.is(current, value)) { return true; }
  if (current === null || value === null || typeof current !== 'object' || typeof value !== 'object') { return false; }
  return isEqual(current, value);
}

export default class BaseModel {
  static singular = 'undefinedSingular';
  static plural = 'undefinedPlural';

  static itemTypeMap = {
    Group: 'groups',
    Discussion: 'discussions',
    Poll: 'polls',
    Outcome: 'outcomes',
    Stance: 'stances',
    Comment: 'comments',
    CommentVote: 'comments',
    Membership: 'memberships',
    MembershipRequest: 'membershipRequests',
    DiscussionTemplate: 'discussionTemplates',
    PollTemplate: 'pollTemplates',
  };

  // fields with one record per value, looked up with collection.by(field, value)
  static uniqueIndices = ['id'];

  // fields that queries commonly filter by equality or $in (see record_store/db.js)
  static indices = [];

  static searchableFields = [];

  // whitelist of attributes to include when serializing the record.
  // leave null to serialize all attributes
  static serializableAttributes = null;

  // what is the key to use when serializing the record?
  static serializationRoot = null;

  // Returns the record's reactive proxy, so `this` in subclass constructors and
  // in methods called on the record is reactive, and writes to it update the UI.
  constructor(attributes) {
    if (attributes == null) { attributes = {}; }
    this.processing = false; // not returning/throwing on already processing rn
    this._version = 0;
    this.attributeNames = [];
    this.saveDisabled = false;
    this.saveFailed = false;
    this.beforeSaves = [];
    this.errors = [];
    this.setErrors();
    if (this.relationships != null) { this.buildRelationships(); }
    this.update(this.defaultValues());
    this.update(attributes);
    this.afterConstruction();
    return reactive(this);
  }

  collabKeyParams() {
    return [];
  }

  collabKey(field, userId) {
    return compact((this.isNew() ?
      [this.constructor.singular, 'new', userId, this.collabKeyParams(), field]
    :
      [this.constructor.singular, this.id, field]
    ).flat()).join("-");
  }

  afterConstruction() {}

  defaultValues() { return {}; }

  clone() {
    const cloneAttributes = {};
    each(this.attributeNames, attr => {
      if (isArray(this[attr])) {
        cloneAttributes[attr] = this[attr].slice(0);
      } else {
        cloneAttributes[attr] = this[attr];
      }
      return true;
    });
    return new this.constructor(cloneAttributes);
  }

  inCollection() {
    return collectionOf(this) !== undefined;
  }

  update(attributes) {
    return this.baseUpdate(attributes);
  }

  // Assign only the attributes that changed. Imported JSON always carries new
  // Date objects and arrays, so assigning equal values would re-run every
  // computed, watcher and render that reads them.
  baseUpdate(attributes) {
    const raw = toRaw(this);
    const record = reactive(this);
    let changed = false;
    let namesAdded = null;
    Object.keys(attributes).forEach(key => {
      const value = attributes[key];
      if (!raw.attributeNames.includes(key)) { (namesAdded ||= []).push(key); }
      if (sameValue(raw[key], value)) { return; }
      record[key] = value;
      changed = true;
    });
    if (namesAdded) { raw.attributeNames = raw.attributeNames.concat(namesAdded); }
    if (changed && this.inCollection()) { collectionOf(this).update(this); }
  }

  attributeIsBlank(attributeName) {
    const doc = new DOMParser().parseFromString(this[attributeName], 'text/html');
    const o = (doc.body.textContent || "").trim();
    return ['null', 'undefined', ''].includes(o);
  }

  serialize() {
    return this.baseSerialize();
  }

  baseSerialize() {
    const wrapper = {};
    const data = {};
    const paramKey = snakeCase(this.constructor.serializationRoot || this.constructor.singular);

    if (this._destroy) { data._destroy = this._destroy; }
    each(this.constructor.serializableAttributes || this.attributeNames, attributeName => {
      const snakeName = snakeCase(attributeName);
      const camelName = camelCase(attributeName);
      if (utils.isTimeAttribute(camelName) && this[camelName]) {
        data[snakeName] = this[camelName].toISOString();
      } else {
        data[snakeName] = this[camelName];
      }
      return true;
    }); // so if the value is false we don't break the loop

    wrapper[paramKey] = data;
    return wrapper;
  }

  relationships() {}

  buildRelationships() {
    this.views = {};
    return this.relationships();
  }

  hasMany(name, userArgs) {
    if (userArgs == null) { userArgs = {}; }
    const args = defaults(userArgs, {
      from: name,
      with: this.constructor.singular + 'Id',
      of: 'id',
      find: {}
    });

    const record = reactive(this);
    return this[name] = () => {
      const find = Object.assign({}, {[args.with]: record[args.of]},  args.find);
      if (userArgs.orderBy) {
        return orderBy(Records[args.from].find(find), userArgs.orderBy);
      } else {
        return Records[args.from].find(find);
      }
    };
  }

  belongsTo(name, userArgs) {
    const values = {
      from: name + 's',
      by: name + 'Id'
    };

    const args = assign(values, userArgs);

    const record = reactive(this);
    this[name] = () => {
      if (record[args.by]) {
        let obj;
        if (obj = Records[args.from].find(record[args.by])) { return obj; }
        if (this.constructor.lazyLoad) {
          obj = Records[args.from].create({id: record[args.by]});
          Records[args.from].addMissing(record[args.by]);
          return obj;
        }
      }
      return Records[args.from].nullModel();
    };
    this[name+'Is'] = obj => Records[args.from].find(record[args.by]) === obj;
  }

  belongsToPolymorphic(name) {
    const record = reactive(this);
    this[name] = () => {
      const typeColumn = `${name}Type`;
      const idColumn = `${name}Id`;
      return Records[BaseModel.itemTypeMap[record[typeColumn]]].find(record[idColumn]);
    };
  }

  isA(...models) {
    return includes(models, this.constructor.singular);
  }

  namedId() {
    return { [`${this.constructor.singular}_id`]: this.id };
  }

  bestNamedId() {
    return this.namedId();
  }

  isNew() {
    return (this.id == null);
  }

  keyOrId() {
    if (this.key != null) {
      return this.key;
    } else {
      return this.id;
    }
  }

  remove() {
    this.beforeRemove();
    if (this.inCollection()) {
      return collectionOf(this).remove(this);
    }
  }

  destroy() {
    this.processing = true;
    this.beforeDestroy();
    this.remove();
    return Records[this.constructor.plural].remote.destroy(this.keyOrId())
    .finally(() => {
      this.processing = false;
    });
  }

  beforeDestroy() {}

  beforeRemove() {}

  discard() {
    this.processing = true;
    return Records[this.constructor.plural].remote.discard(this.keyOrId())
    .finally(() => {
      this.processing = false;
    });
  }

  undiscard() {
    this.processing = true;
    return Records[this.constructor.plural].remote.undiscard(this.keyOrId())
    .finally(() => {
      this.processing = false;
    });
  }

  beforeSave() { return true; }

  prepareForSave() {
    this.beforeSave();
    this.beforeSaves.forEach(f => f());
  }

  save() {
    this.processing = true;
    this.prepareForSave();

    if (this.isNew()) {
      return Records[this.constructor.plural].remote.create(this.serialize())
      .then(data => this.saveSuccess(data), data => this.saveError(data))
      .finally(() => { this.processing = false; });
    } else {
      return Records[this.constructor.plural].remote.update(this.keyOrId(), this.serialize())
      .then(data => this.saveSuccess(data), data => this.saveError(data))
      .finally(() => { this.processing = false; });
    }
  }

  saveSuccess(data) {
    this.saveFailed = false;
    return data;
  }

  saveError(data) {
    this.saveFailed = true;
    this.setErrors(data.errors);
    throw data;
  }

  setErrors(errorList) {
    if (errorList == null) { errorList = []; }
    this.errors = {}

    each(errorList, (errors, key) => {
      this.errors[camelCase(key)] = errors
      return true
    });
  }

  isValid() {
    return this.errors.length > 0;
  }

  edited() {
    return this.versionsCount > 1;
  }
};
