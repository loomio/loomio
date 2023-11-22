import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import GroupModel           from '@/shared/models/group_model';
import Session              from '@/shared/services/session';
import EventBus             from '@/shared/services/event_bus';
import { head } from 'lodash-es';
import NullGroupModel   from '@/shared/models/null_group_model';

export default class GroupRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = GroupModel;
    this.baseConstructor(recordStore);
  }

  nullModel() { return new NullGroupModel(); }

  fuzzyFind(id) {
    // could be id or key or handle
    return this.find(id) || head(this.find({handle: `${id}`.toLowerCase()}));
  }

  findOrFetch(id, options) {
    if (options == null) { options = {}; }
    const record = this.fuzzyFind(id);
    if (record) {
      this.remote.fetchById(id, options);
      return Promise.resolve(record);
    } else {
      return this.remote.fetchById(id, options)
      .then(() => this.fuzzyFind(id));
    }
  }

  fetchByParent(parentGroup) {
    return this.fetch({
      path: `${parentGroup.id}/subgroups`});
  }

  fetchExploreGroups(query, options) {
    if (options == null) { options = {}; }
    options['q'] = query;
    return this.fetch({
      params: options});
  }

  getExploreResultsCount(query, options) {
    if (options == null) { options = {}; }
    options['q'] = query;
    return this.fetch({
      path: 'count_explore_results',
      params: options
    });
  }

  getHandle({name, parentHandle}) {
    return this.fetch({
      path: 'suggest_handle',
      params: {name, parent_handle: parentHandle}});
  }
};
