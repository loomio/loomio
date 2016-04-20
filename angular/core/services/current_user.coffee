angular.module('loomioApp').factory 'CurrentUser', ($rootScope, Records, AppConfig) ->

  login: (data) ->
    return unless data.current_user and data.current_user.id
    Records.import(data)

    _.merge AppConfig,
      currentUserId: data.current_user.id
      inboxLoaded: false
      notificationsLoaded: false
      membershipsLoaded: true

    if !currentUser.restricted?
      Records.discussions.fetchInbox().then ->
        AppConfig.inboxLoaded = true
        $rootScope.$broadcast 'currentUserInboxLoaded'

      Records.notifications.fetchMyNotifications().then ->
        AppConfig.notificationsLoaded = true
        $rootScope.$broadcast 'notificationsLoaded'

    $rootScope.$broadcast 'loggedIn', @current()
    @current()

  current: ->
    Records.users.find(AppConfig.currentUserId) or Records.users.build()
