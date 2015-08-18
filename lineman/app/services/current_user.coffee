angular.module('loomioApp').factory 'CurrentUser', ($rootScope, Records, AppConfig) ->
  Records.import(AppConfig.seedRecords)

  Records.memberships.fetchMyMemberships().then ->
    $rootScope.$broadcast 'currentUserMembershipsLoaded'

  Records.users.find(AppConfig.currentUserId)
