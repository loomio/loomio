angular.module('loomioApp').factory 'UserAuthService', (Records, $http) ->
  new class UserAuthService
    constructor: ->
      @currentUser = null
      @inboxPinned = false

    fetchCurrentUser: ->
      $http.get('/api/v1/faye/who_am_i').then (response) =>
        @currentUser = Records.users.build(response.data.user)
        Records.memberships.fetchMyMemberships()

    logout: ->
      $http.delete('/api/vi/sessions').then (response) ->
        console.log(response)

    can: (action, object) ->
