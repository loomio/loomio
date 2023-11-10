import utils from './utils';
import Vue from 'vue';
import { isEqual } from 'date-fns';
import { camelCase, union, each, isArray, keys, filter, snakeCase, defaults, orderBy, assign, includes, pick } from 'lodash-es';

export default class BaseModel {
  static singular = 'undefinedSingular';
  static plural = 'undefinedPlural';

  static eventTypeMap = {
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

  // indicate to Loki our 'primary keys' - it promises to make these fast to lookup by.
  static uniqueIndices = ['id'];

  // list of other attributes to index
  static indices = [];

  static searchableFields = [];

  // whitelist of attributes to include when serializing the record.
  // leave null to serialize all attributes
  static serializableAttributes = null;

  // what is the key to use when serializing the record?
  static serializationRoot = null;

  constructor(recordsInterface, attributes) {
    this.inCollection = this.inCollection.bind(this);
    this.remove = this.remove.bind(this);
    this.destroy = this.destroy.bind(this);
    this.beforeDestroy = this.beforeDestroy.bind(this);
    this.beforeRemove = this.beforeRemove.bind(this);
    this.discard = this.discard.bind(this);
    this.undiscard = this.undiscard.bind(this);
    this.save = this.save.bind(this);
    this.saveSuccess = this.saveSuccess.bind(this);
    this.saveError = this.saveError.bind(this);
    if (attributes == null) { attributes = {}; }
    this.processing = false; // not returning/throwing on already processing rn
    this._version = 0;
    this.attributeNames = [];
    this.unmodified = {};
    this.afterUpdateFns = [];
    this.saveDisabled = false;
    this.saveFailed = false;
    this.beforeSaves = [];
    this.setErrors();
    Object.defineProperty(this, 'recordsInterface', {value: recordsInterface, enumerable: false});
    Object.defineProperty(this, 'recordStore', {value: recordsInterface.recordStore, enumerable: false});
    Object.defineProperty(this, 'remote', {value: recordsInterface.remote, enumerable: false});
    if (this.relationships != null) { this.buildRelationships(); }
    this.update(this.defaultValues());
    this.update(attributes);
    this.afterConstruction();
  }

  bumpVersion() {
    return this._version = this._version + 1;
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
    return new this.constructor(this.recordsInterface, cloneAttributes);
  }

  inCollection() {
    return this['$loki'];
  }

  update(attributes) {
    return this.baseUpdate(attributes);
  }

  afterUpdate(fn) {
    return this.afterUpdateFns.push(fn);
  }

  baseUpdate(attributes) {
    this.bumpVersion();
    this.attributeNames = union(this.attributeNames, keys(attributes));
    each(attributes, (value, key) => {
      this.unmodified[key] = value;
      Vue.set(this, key, value);
      return true;
    });

    if (this.inCollection()) { this.recordsInterface.collection.update(this); }

    return this.afterUpdateFns.forEach(fn => fn(this));
  }

  attributeIsModified(attributeName) {
    const strip = function(val) {
      const doc = new DOMParser().parseFromString(val, 'text/html');
      const o = (doc.body.textContent || "").trim();
      if (['null', 'undefined'].includes(o)) {
        return '';
      } else {
        return o;
      }
    };

    const original = this.unmodified[attributeName];
    const current = this[attributeName];
    if (utils.isTimeAttribute(attributeName)) {
      return !((original === current) || isEqual(original, current));
    } else {
      if (strip(original) === strip(current)) { return false; }
      // console.log("#{attributeName}: #{strip(original)}, #{strip(current)}")
      return original !== current;
    }
  }

  modifiedAttributes() {
    return filter(this.attributeNames, name => {
      return this.attributeIsModified(name);
    });
  }

  isModified() {
    return this.modifiedAttributes().length > 0;
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

    return this[name] = () => {
      const find = Object.assign({}, {[args.with]: this[args.of]},  args.find);
      if (userArgs.orderBy) {
        return orderBy(this.recordStore[args.from].find(find), userArgs.orderBy);
      } else {
        return this.recordStore[args.from].find(find);
      }
    };
  }

  belongsTo(name, userArgs) {
    const values = {
      from: name + 's',
      by: name + 'Id'
    };

    const args = assign(values, userArgs);

    this[name] = () => {
      if (this[args.by]) {
        let obj;
        if (obj = this.recordStore[args.from].find(this[args.by])) { return obj; }
        if (this.constructor.lazyLoad) {
          obj = this.recordStore[args.from].create({id: this[args.by]});
          this.recordStore[args.from].addMissing(this[args.by]);
          return obj;
        }
      }
      return this.recordStore[args.from].nullModel();
    };
    return this[name+'Is'] = obj => this.recordStore[args.from].find(this[args.by]) === obj;
  }

  belongsToPolymorphic(name) {

    return this[name] = () => {
      const typeColumn = `${name}Type`;
      const idColumn = `${name}Id`;
      return this.recordStore[BaseModel.eventTypeMap[this[typeColumn]]].find(this[idColumn]);
    };
  }

  translationOptions() {}

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
      return this.recordsInterface.collection.remove(this);
    }
  }

  destroy() {
    this.processing = true;
    this.beforeDestroy();
    this.remove();
    return this.remote.destroy(this.keyOrId())
    .finally(() => {
      return this.processing = false;
    });
  }

  beforeDestroy() {}

  beforeRemove() {}

  discard() {
    this.processing = true;
    return this.remote.discard(this.keyOrId())
    .finally(() => {
      return this.processing = false;
    });
  }

  undiscard() {
    this.processing = true;
    return this.remote.undiscard(this.keyOrId())
    .finally(() => {
      return this.processing = false;
    });
  }

  beforeSave() { return true; }

  save() {
    this.processing = true;
    this.beforeSave();
    this.beforeSaves.forEach(f => f());
  
    if (this.isNew()) {
      return this.remote.create(this.serialize())
      .then(this.saveSuccess, this.saveError)
      .finally(() => { return this.processing = false; });
    } else {
      return this.remote.update(this.keyOrId(), this.serialize())
      .then(this.saveSuccess, this.saveError)
      .finally(() => { return this.processing = false; });
    }
  }

  saveSuccess(data) {
    this.saveFailed = false;
    this.unmodified = pick(this, this.attributeNames);
    return data;
  }

  saveError(data) {
    this.saveFailed = true;
    this.setErrors(data.errors);
    throw data;
  }

  discardChanges() {
    return this.attributeNames.forEach(key => {
      return Vue.set(this, key, this.unmodified[key]);
    });
  }

  setErrors(errorList) {
    if (errorList == null) { errorList = []; }
    Vue.set(this, 'errors', {});
    return each(errorList, (errors, key) => {
      return Vue.set(this.errors, camelCase(key), errors);
    });
  }

  isValid() {
    return this.errors.length > 0;
  }

  edited() {
    return this.versionsCount > 1;
  }
};
