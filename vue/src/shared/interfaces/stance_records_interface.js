/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let StanceRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import StanceModel          from '@/shared/models/stance_model';

export default StanceRecordsInterface = (function() {
  StanceRecordsInterface = class StanceRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = StanceModel;
    }
  };
  StanceRecordsInterface.initClass();
  return StanceRecordsInterface;
})();

  // fetchMyStances: (groupKey, options = {}) ->
  //   options['group_id'] = groupKey
  //   @fetch
  //     path: 'my_stances'
  //     params: options

  // fetchMyStancesByDiscussion: (discussionKey, options = {}) ->
  //   options['discussion_id'] = discussionKey
  //   @fetch
  //     path: 'my_stances'
  //     params: options
