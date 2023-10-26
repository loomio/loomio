/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import Records from '@/shared/services/records';
import utils         from '@/shared/record_store/utils';
import RestfulClient from '@/shared/record_store/restful_client';
import Vue from 'vue';
import {merge, camelCase, defaults, max, orderBy, uniq, map } from 'lodash';

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
      this.total = data.meta.total;
      const firstId = data[data.meta.root][0][this.order];
      const lastId = data[data.meta.root][(data[data.meta.root].length - 1)][this.order];
      Vue.set(this.pageWindow, page, [lastId,firstId]);
      Vue.set(this.pageIds, page, map(data[data.meta.root], 'id'));
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
