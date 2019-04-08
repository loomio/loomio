import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import NotificationModel    from '@/shared/models/notification_model'

export default class NotificationRecordsInterface extends BaseRecordsInterface
  model: NotificationModel

  viewed: ->
    any = false
    _.each @collection.find(viewed: { $ne: true}), (n) =>
      any = true
      n.update(viewed: true)

    @remote.post 'viewed' if any
