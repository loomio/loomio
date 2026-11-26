import Records from '@/shared/services/records';
import utils from '@/shared/record_store/utils';
import RestfulClient from '@/shared/record_store/restful_client';
import { merge, map } from 'lodash-es';

export default class PageLoader {
  constructor(opts) {
    this.remote = new RestfulClient;
    this.loading = false;
    this.params = opts.params;
    this.path = opts.path;
    this.per = opts.params.limit || opts.params.per;
    this.order = opts.order;
    this.total = 0;
    this.pageWindow = {};
    this.pageIds = {};
    this.err = null;
    this.status = null;
  }

  totalPages() {
    return Math.ceil(parseFloat(this.total) / parseFloat(this.per));
  }

  fetch(page) {
    this.loading = true;
    const offsetParam = this.params.limit ? { offset: (page - 1) * this.per } : { from: (page - 1) * this.per };
    return this.remote.fetch({
      path: this.path,
      params: merge(offsetParam, this.params)
    }).then(json => {
      const data = utils.deserialize(json);
      const records = data[data.meta.root];
      this.total = data.meta.total;
      if (records.length) {
        const firstVal = this.order ? records[0][this.order] : null;
        const lastVal = this.order ? records[records.length - 1][this.order] : null;
        this.pageWindow[page] = firstVal <= lastVal ? [firstVal, lastVal] : [lastVal, firstVal];
        this.pageIds[page] = map(records, 'id');
      } else {
        this.pageWindow[page] = null;
        this.pageIds[page] = [];
      }
      return Records.importREADY(data);
    }).catch(err => {
      this.err = err;
      return this.status = err.status;
    }).finally(() => {
      return this.loading = false;
    });
  }
}
