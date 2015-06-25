angular.module('loomioApp').factory 'CurrentUser', (Records) ->
  currentUser = null
  if window? and window.Loomio?
    window.Loomio.seedRecords.users = [] unless window.Loomio.seedRecords.users?
    window.Loomio.seedRecords.users.push window.Loomio.seedRecords.current_user
    Records.import(window.Loomio.seedRecords)
    Records.memberships.fetchMyMemberships()
    currentUser =  Records.users.find(window.Loomio.currentUserId)

  currentUser
