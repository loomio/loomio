angular.module('loomioApp').factory 'CurrentUser', ($rootScope, Records, AppConfig) ->
  Records.import(AppConfig.seedRecords)

  Records.memberships.fetchMyMemberships().then ->
    AppConfig.membershipsLoaded = true
    $rootScope.$broadcast 'currentUserMembershipsLoaded'

  Records.discussions.fetchInbox().then ->
    AppConfig.inboxLoaded = true
    $rootScope.$broadcast 'currentUserInboxLoaded'


  Records.notifications.fetchMyNotifications().then ->
    AppConfig.notificationsLoaded = true
    $rootScope.$broadcast 'notificationsLoaded'

  Records.users.find(AppConfig.currentUserId)
