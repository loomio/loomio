angular.module('loomioApp').factory 'User', ($rootScope, Records, AppConfig, IntercomService, MessageChannelService) ->

  login: (data) ->
    return unless data.current_user and data.current_user.id
    Records.import(data)

    _.merge AppConfig,
      currentUserId: data.current_user.id
      inboxLoaded: false
      notificationsLoaded: false

    Records.discussions.fetchInbox().then ->
      AppConfig.inboxLoaded = true
      $rootScope.$broadcast 'currentUserInboxLoaded'

    Records.notifications.fetchMyNotifications().then ->
      AppConfig.notificationsLoaded = true
      $rootScope.$broadcast 'notificationsLoaded'

    IntercomService.boot(@current())
    MessageChannelService.subscribe()

    @current()

  current: ->
    Records.users.find(AppConfig.currentUserId) or Records.users.build()
