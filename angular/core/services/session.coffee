angular.module('loomioApp').factory 'Session', ($rootScope, Records, AppConfig) ->

  login: (data) ->
    return unless data.current_user and data.current_user.id
    data.users = data.users || []
    data.users.push(data.current_user)
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

    $rootScope.$broadcast 'loggedIn', @user()
    @user()

  homePath: ->
    switch @user().topLevelGroups().length
      when 0 then '/explore'
      when 1 then LmoUrlService.group(@user().topLevelGroups()[0])
      else        '/dashboard'

  user: ->
    Records.users.find(AppConfig.currentUserId) or Records.users.build()
