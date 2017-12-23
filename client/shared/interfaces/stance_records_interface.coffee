BaseRecordsInterface = require 'shared/interfaces/base_records_interface.coffee'
StanceModel          = require 'shared/models/stance_model.coffee'

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
