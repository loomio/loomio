/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let PollRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import PollModel            from '@/shared/models/poll_model';
import {merge} from 'lodash';

export default PollRecordsInterface = (function() {
  PollRecordsInterface = class PollRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = PollModel;
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
  PollRecordsInterface.initClass();
  return PollRecordsInterface;
})();

  // fetchByGroup: (groupKey, options = {}) ->
  //   @search merge(options, {group_key: groupKey})
