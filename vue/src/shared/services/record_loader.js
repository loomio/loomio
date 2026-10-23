import Records from '@/shared/services/records';
import {merge, camelCase, defaults } from 'lodash-es';

export default class RecordLoader {
  constructor(opts) {
    if (opts == null) { opts = {}; }
    this.exhausted = false;
    this.loading = false;
    this.collection   = opts.collection;
    const pagination = opts.params?.limit != null ? {offset: 0, order: 'id'} : {from: 0, per: 25, order: 'id'};
    this.params       = merge(pagination, opts.params);
    this.path         = opts.path;
    // @numLoaded    = opts.numLoaded or 0
    this.total        = 0;
    this.err = null;
    this.status = null;
  }

  reset() {
    return this.params[this.params.limit != null ? 'offset' : 'from'] = 0;
  }
    // @numLoaded = 0

  fetchRecords(opts) {
    if (opts == null) { opts = {}; }
    this.loading = true;
    this.err = null;
    this.status = null;
    this.params = defaults({}, opts, this.params);
    return Records[camelCase(this.collection)].fetch({
      path: this.path,
      params: this.params}).then(data => {
      this.total = data.meta.total;
      const offsetKey = this.params.limit != null ? 'offset' : 'from';
      this.params[offsetKey] += this.params.limit ?? this.params.per;
      this.exhausted = this.params[offsetKey] >= this.total;
      return data;
    }).finally(() => {
      return this.loading = false;
    }).catch(err => {
      this.err = err;
      return this.status = err.status;
    });
  }
}
