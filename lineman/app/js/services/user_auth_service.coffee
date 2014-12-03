angular.module('loomioApp').factory 'UserAuthService', (Records, $http) ->
  new class UserAuthService
    constructor: ->
      # this line is really inital app setup but I'm not actually sure where that is.
      if window? and window.Loomio?
        Records.import(window.Loomio.seedRecords)
        @currentUser = Records.users.find(window.Loomio.currentUserId)
      @inboxPinned = false
