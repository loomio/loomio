import Records from '@/shared/services/records';
import utils         from '@/shared/record_store/utils';
import RestfulClient from '@/shared/record_store/restful_client';
import {merge, orderBy, uniq, map } from 'lodash-es';

export default class PageLoader {
  constructor(opts) {
    this.remote = new RestfulClient;
    this.loading = false;
    this.params = opts.params;
    this.path = opts.path;
    this.per = opts.params.per;
    this.order = opts.order;
    this.total = 0;
    this.pageWindow = {};
    this.pageIds = {};
    this.err = null;
    this.status = null;
  }

  totalPages() {
    return Math.ceil(parseFloat(this.total) / parseFloat(this.params.per));
  }

  fetch(page) {
    this.loading = true;
    return this.remote.fetch({
      path: this.path,
      params: merge({from: ((page - 1) * this.per)}, this.params)}).then(json => {
      const data = utils.deserialize(json);
      const records = data[data.meta.root];
      this.total = data.meta.total;
      if (records.length) {
        const firstId = records[0][this.order];
        const lastId = records[(records.length - 1)][this.order];
        this.pageWindow[page] = [lastId,firstId];
        this.pageIds[page] = map(records, 'id');
      } else {
        this.pageWindow[page] = null;
        this.pageIds[page] = [];
      }
      // console.log 'page', page, 'discussions.length', data.discussions.length, 'first', firstId, 'last', lastId, 'groupIds!', orderBy uniq(map(data['discussions'], 'groupId'))
      return Records.importREADY(data);
    }).catch(err => {
      this.err = err;
      return this.status = err.status;
    }).finally(() => {
      return this.loading = false;
    });
  }
}
