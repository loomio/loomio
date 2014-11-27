angular.module('loomioApp').factory 'MessageChannelService', ($http, Records, CommentModel, EventModel) ->
  new class MessageChannelService
    subscribeSuccess: (subscription, onMessageReceived) ->
      PrivatePub.sign(subscription)
      console.log 'subscribed to channel:', subscription.channel
      PrivatePub.subscribe subscription.channel, (data, channel) =>
        @messageReceived(data, onMessageReceived)

    subscribeTo: (channel, onMessageReceived) ->
      $http.post('/api/v1/faye/subscribe', channel: channel).then (response) =>
          subscription = response.data
          PrivatePub.sign(subscription)
          console.log 'subscribed response:', response
          PrivatePub.subscribe subscription.channel, (data, channel) =>
            @messageReceived(data, onMessageReceived)

    messageReceived: (data, onMessageReceived) ->
      console.log 'message received: ', data
      if data.memo?
        console.log 'new memo!', data.memo
        memo = data.memo
        if memo.kind == 'comment_destroyed'
          if comment = Records.comments.get(memo.data.comment_id)
            comment.destroy()
        if memo.kind == 'comment_updated'
          Records.comments.new(memo.data.comment)
          Records.import(memo.data)
        if memo.kind == 'comment_unliked'
          if comment = Records.comments.get(memo.data.comment_id)
            comment.removeLikerId(memo.data.user_id)

      if data.event?
        console.log 'new event', data.event
        Records.events.new(data.event)

      # maybe indent this one
      Records.import(data)
      onMessageReceived(data) if onMessageReceived?

