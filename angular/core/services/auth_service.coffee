angular.module('loomioApp').factory 'AuthService', (Records, RestfulClient) ->
  new class AuthService
    signIn: (email, password) ->
      Records.sessions.build(email: email, password: password).save()

    signUp: (email, name) ->
      Records.registrations.build(email: email, name: name).save()

    sendLoginLink: (email) ->
      new RestfulClient('login_tokens').post('', email: email)

    forgotPassword: (email) ->
      Records.users.remote.post
        path: 'password'
        params: {email: email}
