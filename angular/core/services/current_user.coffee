angular.module('loomioApp').factory 'CurrentUser', ($rootScope, Records, AppConfig) ->
  Records.import(AppConfig.currentUserData)
  currentUser = AppConfig.currentUserData.current_user or {}

  # User has an email (ie, has a Loomio account)
  if currentUser.id?
    AppConfig.membershipsLoaded = true
    $rootScope.$broadcast 'currentUserMembershipsLoaded'

    # User is authenticated (ie, not signed in via an unsubscribe token)
    if !currentUser.restricted?
      Records.discussions.fetchInbox().then ->
        AppConfig.inboxLoaded = true
        $rootScope.$broadcast 'currentUserInboxLoaded'

      Records.notifications.fetchMyNotifications().then ->
        AppConfig.notificationsLoaded = true
        $rootScope.$broadcast 'notificationsLoaded'

  Records.users.find(currentUser.id) or Records.users.build()
