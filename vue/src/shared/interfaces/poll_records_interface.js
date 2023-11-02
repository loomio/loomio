import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import PollModel            from '@/shared/models/poll_model';
import {merge} from 'lodash';

export default class PollRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = PollModel;
    this.baseConstructor(recordStore);
  }

  fetchFor(model, options) {
    if (options == null) { options = {}; }
    options[`${model.constructor.singular}_key`] = model.key;
    return this.search(options);
  }

  search(options) {
    if (options == null) { options = {}; }
    return this.fetch({
      path: 'search',
      params: options
    });
  }

  searchResultsCount(options) {
    if (options == null) { options = {}; }
    return this.fetch({
      path: 'search_results_count',
      params: options
    });
  }
};
