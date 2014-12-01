angular.module('loomioApp').factory 'UserAuthService', (Records, $http) ->
  new class UserAuthService
    constructor: ->
      @currentUser = Records.users.initialize(window.currentUserData.user)
      @inboxPinned = false

    logout: ->
      $http.delete('/api/vi/sessions').then (response) ->
        console.log(response)

    can: (action, object) ->
