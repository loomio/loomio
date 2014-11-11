angular.module('loomioApp').factory 'MessageChannelService', ($http, RecordStoreService, EventModel) ->
  new class MessageChannelService
    subscribeSuccess: (subscription, onMessageReceived) ->
      PrivatePub.sign(subscription)
      console.log 'subscribed to channel:', subscription.channel
      PrivatePub.subscribe subscription.channel, (data, channel) =>
        @messageReceived(data, onMessageReceived)

    subscribeTo: (channel, onMessageReceived) ->
      $http.post('/api/v1/faye/subscribe', channel: channel).then (response) =>
        @subscribeSuccess(response.data, onMessageReceived)

    messageReceived: (data, onMessageReceived) ->
      console.log 'message received: ', data
      if data.memo?
        console.log 'new memo!', data.memo
        memo = data.memo
        if memo.kind == 'comment_destroyed'
          if comment = RecordStoreService.get('comments', memo.comment_id)
            comment.destroy()

      if data.event?
        console.log 'new event', data.event
        event = new EventModel(data.event)
        RecordStoreService.put(event)

      RecordStoreService.importRecords(data)
      onMessageReceived(data) if onMessageReceived?

