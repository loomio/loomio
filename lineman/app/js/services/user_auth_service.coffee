angular.module('loomioApp').factory 'UserAuthService', (RecordStoreService, UserModel, $http) ->
  new class UserAuthService
    constructor: ->
      @currentUser = null

    fetchCurrentUser: ->
      $http.get('/api/v1/sessions/current').then (response) =>
        user = new UserModel(response.data.user)
        RecordStoreService.put(user)
        @currentUser = user

    login: (credentials, success, failure) ->
      $http.post('/api/v1/sessions', credentials).then (response) ->
        console.log(response)

    logout: ->
      $http.delete('/api/v1/sessions/sign_out').then (resposne) ->
        console.log(response)

    forgotPassword: (username) ->
