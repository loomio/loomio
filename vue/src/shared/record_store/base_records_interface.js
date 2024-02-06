import RestfulClient from './restful_client';
import {each, keys, isNumber, isString, isArray, debounce, difference, uniq} from 'lodash-es';
import Vue           from 'vue';

export default class BaseRecordsInterface {
  constructor(recordStore) {
    this.model = 'undefinedModel';
    this.apiEndPoint = null;
  }

  baseConstructor(recordStore) {
    this.views = [];
    this.missingIds = [];
    this.fetchedIds = [];

    this.fetchMissing = debounce(function() {
      const xids = difference(this.missingIds, this.fetchedIds).join('x');
      if (xids.length === 0) { return; }

      this.fetch({
        path: '',
        params: {
          xids
        }
      });

      this.fetchedIds = uniq(this.fetchedIds.concat(this.missingIds));
      return this.missingIds = [];
    } , 500);

    this.recordStore = recordStore;
    this.collection = this.recordStore.db.addCollection((this.collectionName || this.model.plural), {indices: this.model.indices});
    each(this.model.uniqueIndices, name => {
      return this.collection.ensureUniqueIndex(name);
    });

    this.remote = new RestfulClient(this.apiEndPoint || this.model.plural);

    this.remote.onSuccess = data => {
      this.recordStore.importJSON(data);
      return data;
    };

    this.remote.onUploadSuccess = data => {
      this.recordStore.importJSON(data);
      return data;
    };
  }

  addMissing(id) {
    this.missingIds.push(id);
    return this.fetchMissing();
  }

  fetchAnyMissingById(allIds) {
    const presentIds = this.collection.chain().find({id: {$in: allIds}}).data().map(r => r.id);
    this.missingIds = uniq(this.missingIds.concat(difference(allIds, presentIds)));
    this.fetchMissing();
  }

  nullModel() { return null; }
  all() {
    return this.collection.data;
  }

  build(attributes) {
    if (attributes == null) { attributes = {}; }
    const record = new this.model(this, attributes);
    return Vue.observable(record);
  }

  create(attributes) {
    if (attributes == null) { attributes = {}; }
    const record = this.build(attributes);
    this.collection.insert(record);
    return record;
  }

  fetch(args) {
    return this.remote.fetch(args);
  }

  importRecord(attributes) {
    let record;
    if (attributes.key != null) { record = this.find(attributes.key); }
    if ((attributes.id != null) && (record == null)) { record = this.find(attributes.id); }
    if (record) {
      record.update(attributes);
    } else {
      record = this.create(attributes);
    }
    return record;
  }

  findOrFetchById(id, params) {
    if (params == null) { params = {}; }
    const record = this.find(id);
    if (record) {
      this.remote.fetchById(id, params);
      return Promise.resolve(record);
    } else {
      return this.remote.fetchById(id, params).then(data => {
        return this.find(id);
      });
    }
  }

  find(q) {
    if ((q === null) || (q === undefined)) {
      return undefined;
    } else if (isNumber(q)) {
      return this.findById(q);
    } else if (isString(q)) {
      return this.findByKey(q);
    } else if (isArray(q)) {
      if (q.length === 0) {
        return [];
      } else if (isString(q[0])) {
        return this.findByKeys(q);
      } else if (isNumber(q[0])) {
        return this.findByIds(q);
      }
    } else {
      const chain = this.collection.chain();
      each(keys(q), function(key) {
        chain.find({[key]: q[key]});
        return true;
      });
      return chain.data();
    }
  }

  findOrNull(q) {
    const res = this.find(q);
    if (isArray(res) && (res.length === 0)) {
      return null;
    } else {
      return res;
    }
  }

  findById(id) {
    return this.collection.by('id', id);
  }

  findByKey(key) {
    if (this.collection.constraints.unique['key'] != null) {
      return this.collection.by('key', key);
    } else {
      return this.collection.findOne({key});
    }
  }

  findByIds(ids) {
    return this.collection.find({id: {'$in': ids}});
  }

  findByKeys(keys) {
    return this.collection.find({key: {'$in': keys}});
  }
};
