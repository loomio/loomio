BaseRecordsInterface = require 'shared/record_store/base_records_interface.coffee'
NotificationModel    = require 'shared/models/notification_model.coffee'

_ = require 'lodash'

module.exports = class NotificationRecordsInterface extends BaseRecordsInterface
  model: NotificationModel

  viewed: ->
    any = false
    _.each @collection.find(viewed: { $ne: true}), (n) =>
      any = true
      n.update(viewed: true)

    @remote.post 'viewed' if any
