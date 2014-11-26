angular.module('loomioApp').factory 'UserAuthService', (Records, UserModel, MembershipService, $http) ->
  new class UserAuthService
    constructor: ->
      @currentUser = null

    fetchCurrentUser: ->
      $http.get('/api/v1/faye/who_am_i').then (response) =>
        user = Records.users.new(response.data.user)
        @currentUser = user
        MembershipService.fetchMyMemberships()

    logout: ->
      $http.delete('/api/vi/sessions').then (response) ->
        console.log(response)

    can: (action, object) ->
