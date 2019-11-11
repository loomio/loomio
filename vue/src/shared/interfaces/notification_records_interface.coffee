import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import NotificationModel    from '@/shared/models/notification_model'

export default class NotificationRecordsInterface extends BaseRecordsInterface
  model: NotificationModel

  fetchNotifications: (query, options = {}) ->
    options['q'] = query
    @fetch
      params: options

  viewed: ->
    any = false
    @collection.find(viewed: { $ne: true}).forEach (n) =>
      any = true
      n.update(viewed: true)

    @remote.post 'viewed' if any
