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
      if data.memo?
        switch data.memo.kind
          when 'comment_destroyed'
            if comment = Records.comments.find(memo.data.comment_id)
              comment.destroy()
          when 'comment_updated'
            Records.comments.initialize(memo.data.comment)
            Records.import(memo.data)
          when 'comment_unliked'
            if comment = Records.comments.find(memo.data.comment_id)
              comment.removeLikerId(memo.data.user_id)

      if data.event?
        data.events = [] unless data.events?
        data.events.push(data.event)

      if data.notification?
        data.notifications = [] unless data.notifications?
        data.events.push(data.notification)

      Records.import(data)
      onMessageReceived(data) if onMessageReceived?

