BaseRecordsInterface = require 'shared/record_store/base_records_interface'
StanceModel          = require 'shared/models/stance_model'

module.exports = class StanceRecordsInterface extends BaseRecordsInterface
  model: StanceModel

  fetchMyStances: (groupKey, options = {}) ->
    options['group_id'] = groupKey
    @fetch
      path: 'my_stances'
      params: options

  fetchMyStancesByDiscussion: (discussionKey, options = {}) ->
    options['discussion_id'] = discussionKey
    @fetch
      path: 'my_stances'
      params: options
