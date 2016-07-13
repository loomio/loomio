angular.module('loomioApp').factory 'MessageChannelService', ($http, $rootScope, $window, AppConfig, Records, ModalService, SignedOutModal, FlashService) ->
  new class MessageChannelService

    subscribe: (options = {}) ->
      $http.post('/api/v1/message_channel/subscribe', options).then handleSubscriptions

    subscribeToGroup: (group) ->
      @subscribe { group_key: group.key }

    handleSubscriptions = (subscriptions) ->
      _.each subscriptions.data, (subscription) ->
        PrivatePub.sign(subscription)
        PrivatePub.subscribe subscription.channel, (data) ->
          if data.action?
            switch data.action
              when 'logged_out'
                ModalService.open(SignedOutModal, -> preventClose: true) unless AppConfig.loggingOut

          if data.version?
            FlashService.update 'global.messages.app_update', {version: data.version}, 'global.messages.reload', ->
              $window.location.reload()

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
