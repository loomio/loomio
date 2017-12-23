Records       = require 'shared/services/records.coffee'
RestfulClient = require 'shared/interfaces/restful_client.coffee'

module.exports = new class AuthService

  emailStatus: (user) ->
    Records.users.emailStatus(user.email).then (data) => @applyEmailStatus(user, _.first(data.users))

  applyEmailStatus: (user, data) ->
    keys = ['name', 'email', 'avatar_kind', 'avatar_initials', 'gravatar_md5', 'avatar_url', 'has_token', 'has_password', 'email_status']
    user.update _.pick(_.mapKeys(_.pick(data, keys), (v,k) -> _.camelCase(k)), _.identity)
    user

  signIn: (user) ->
    Records.sessions.build(email: user.email, password: user.password).save()

  signUp: (user) ->
    Records.registrations.build(email: user.email, name: user.name, recaptcha: user.recaptcha).save().then ->
      user.sentLoginLink = true

  confirmOauth: ->
    Records.registrations.remote.post('oauth')

  sendLoginLink: (user) ->
    new RestfulClient('login_tokens').post('', email: user.email).then ->
      user.sentLoginLink = true
