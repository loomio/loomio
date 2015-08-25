angular.module('loomioApp').factory 'MessageChannelService', ($http, $rootScope, Records, CommentModel, EventModel, CurrentUser) ->
  new class MessageChannelService
    subscribeTo: (channel, onMessageReceived) ->
      $http.post('/api/v1/message_channel/subscribe', channel: channel).then (response) =>
          subscription = response.data
          PrivatePub.sign(subscription)
          PrivatePub.subscribe subscription.channel, (data, channel) =>
            @messageReceived(data, onMessageReceived)

    subscribeToNotifications: ->
      @subscribeTo "/notifications-#{CurrentUser.id}"

    messageReceived: (data, onMessageReceived) ->
      if data.memo?
        switch data.memo.kind
          when 'comment_destroyed'
            if comment = Records.comments.find(memo.data.comment_id)
              comment.destroy()
          when 'comment_updated'
            Records.comments.import(memo.data.comment)
            Records.import(memo.data)
          when 'comment_unliked'
            if comment = Records.comments.find(memo.data.comment_id)
              comment.removeLikerId(memo.data.user_id)

      if data.event?
        data.events = [] unless _.isArray(data.events)
        data.events.push(data.event)

      if data.notification?
        data.notifications = [] unless _.isArray(data.notifications)
        data.notifications.push(data.notification)

      Records.import(data)

      $rootScope.$digest()
      onMessageReceived(data) if onMessageReceived?
