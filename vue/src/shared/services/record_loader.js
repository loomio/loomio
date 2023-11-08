import Records from '@/shared/services/records';
import {merge, camelCase, defaults, max } from 'lodash-es';

export default class RecordLoader {
  constructor(opts) {
    if (opts == null) { opts = {}; }
    this.exhausted = false;
    this.loading = false;
    this.collection   = opts.collection;
    this.params       = merge({from: 0, per: 25, order: 'id'}, opts.params);
    this.path         = opts.path;
    // @numLoaded    = opts.numLoaded or 0
    this.total        = 0;
    this.err = null;
    this.status = null;
  }

  reset() {
    return this.params['from'] = 0;
  }
    // @numLoaded = 0

  fetchRecords(opts) {
    if (opts == null) { opts = {}; }
    this.loading = true;
    this.params = defaults({}, opts, this.params);
    return Records[camelCase(this.collection)].fetch({
      path: this.path,
      params: this.params}).then(data => {
      this.total = data.meta.total;
      this.params.from = this.params.from + this.params.per;
      this.exhausted = this.params.from >= this.total;
      return data;
    }).finally(() => {
      return this.loading = false;
    }).catch(err => {
      this.err = err;
      return this.status = err.status;
    });
  }
}
