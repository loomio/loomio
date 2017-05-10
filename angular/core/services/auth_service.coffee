angular.module('loomioApp').factory 'AuthService', ($window, Records, RestfulClient) ->
  new class AuthService

    emailStatus: (user) ->
      Records.users.emailStatus(user.email).then (data) ->
        _.merge user, _.first(data.users)

    signIn: (user) ->
      Records.sessions.build(email: user.email, password: user.password).save()

    signUp: (user) ->
      Records.registrations.build(email: user.email, name: user.name, recaptcha: user.recaptcha).save().then ->
        user.sentLoginLink = true

    sendLoginLink: (user) ->
      new RestfulClient('login_tokens').post('', email: user.email).then ->
        user.sentLoginLink = true

    forgotPassword: (user) ->
      Records.users.remote.post('set_password', email: user.email).then ->
        user.sentPasswordLink = true
