angular.module('loomioApp').factory 'User', ($rootScope, Records, AppConfig) ->

  login: (data) ->
    return unless data.current_user and data.current_user.id
    Records.import(data)

    _.merge AppConfig,
      currentUserId: data.current_user.id
      inboxLoaded: false
      notificationsLoaded: false
      membershipsLoaded: true

    if !data.current_user.restricted?
      Records.discussions.fetchInbox().then ->
        AppConfig.inboxLoaded = true
        $rootScope.$broadcast 'currentUserInboxLoaded'

      Records.notifications.fetchMyNotifications().then ->
        AppConfig.notificationsLoaded = true
        $rootScope.$broadcast 'notificationsLoaded'

    $rootScope.$broadcast 'loggedIn', @current()
    @current()

  logout: ->
    _.merge AppConfig,
      currentUserId: null
      inboxLoaded: false
      notificationsLoaded: false
      membershipsLoaded: false

    $rootScope.$broadcast 'loggedOut', @current()

  current: ->
    Records.users.find(AppConfig.currentUserId) or Records.users.build()
