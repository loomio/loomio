angular.module('loomioApp').factory 'AuthService', ($window, Records, RestfulClient) ->
  new class AuthService
    signIn: (user) ->
      Records.sessions.build(email: user.email, password: user.password).save().then ->
        $window.location.reload()

    signUp: (user) ->
      Records.registrations.build(email: user.email, name: user.name).save().then ->
        user.sentLoginLink = true

    sendLoginLink: (user) ->
      new RestfulClient('login_tokens').post('', email: user.email).then ->
        user.sentLoginLink = true

    forgotPassword: (user) ->
      Records.users.remote.post('password', email: user.email).then ->
        user.sentPasswordLink = true
