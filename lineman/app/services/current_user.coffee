angular.module('loomioApp').factory 'CurrentUser', ($rootScope, Records) ->
  currentUser = null
  if window? and window.Loomio?
    window.Loomio.seedRecords.users = [] unless window.Loomio.seedRecords.users?
    window.Loomio.seedRecords.users.push window.Loomio.seedRecords.current_user
    Records.import(window.Loomio.seedRecords)

    currentUser =  Records.users.find(window.Loomio.currentUserId)

    Records.memberships.fetchMyMemberships().then ->
      currentUser.updateFromJSON membershipsLoaded: true
      $rootScope.$broadcast 'currentUserMembershipsLoaded'

    Records.discussions.fetchInbox().then ->
      currentUser.updateFromJSON inboxLoaded: true
      $rootScope.$broadcast 'currentUserInboxLoaded'

  currentUser
