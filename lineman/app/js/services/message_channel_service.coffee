angular.module('loomioApp').factory 'MessageChannelService', ($http, MainRecordStore, CommentModel, EventModel) ->
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
          if comment = MainRecordStore.comments.get(memo.data.comment_id)
            comment.destroy()
        if memo.kind == 'comment_updated'
          comment = new CommentModel(memo.data.comment)
          MainRecordStore.comments.put(comment)
          MainRecordStore.importRecords(memo.data)
        if memo.kind == 'comment_unliked'
          if comment = MainRecordStore.comments.get(memo.data.comment_id)
            comment.removeLikerId(memo.data.user_id)

      if data.event?
        console.log 'new event', data.event
        event = new EventModel(data.event)
        MainRecordStore.put(event)

      # maybe indent this one
      MainRecordStore.importRecords(data)
      onMessageReceived(data) if onMessageReceived?

