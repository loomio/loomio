angular.module('loomioApp').factory 'UserAuthService', (RecordStoreService, UserModel, MembershipService, $http) ->
  new class UserAuthService
    constructor: ->
      @currentUser = null

    fetchCurrentUser: ->
      $http.get('/api/v1/faye/who_am_i').then (response) =>
        user = new UserModel(response.data.user)
        RecordStoreService.put(user)
        @currentUser = user
        MembershipService.fetchMyMemberships()

    logout: ->
      $http.delete('/api/vi/sessions').then (response) ->
        console.log(response)

    can: (action, object) ->
