AppConfig = require 'shared/services/app_config'
Records   = require 'shared/services/records'

{ hardReload } = require 'shared/helpers/window'

module.exports = new class AuthService

  emailStatus: (user) ->
    pendingToken = (AppConfig.pendingIdentity or {}).token
    Records.users.emailStatus(user.email, pendingToken).then (data) =>
      @applyEmailStatus(user, _.first(data.users))

  applyEmailStatus: (user, data = {}) ->
    keys = ['name', 'email', 'avatar_kind', 'avatar_initials', 'email_hash', 'avatar_url', 'has_password', 'email_status', 'legal_accepted']
    user.update _.pick(_.mapKeys(_.pick(data, keys), (v,k) -> _.camelCase(k)), _.identity)
    user.update(hasToken: data.has_token)
    user

  signIn: (user = {}) ->
    Records.sessions.build(name: user.name, email: user.email, password: user.password).save()

  signUp: (user) ->
    Records.registrations.build(
      _.pick(user, ['email', 'name', 'recaptcha', 'legalAccepted'])
    ).save().then (data) ->
      if user.hasToken
        hardReload()
      else
        user.sentLoginLink = true
      data

  confirmOauth: ->
    Records.registrations.remote.post('oauth')

  sendLoginLink: (user) ->
    Records.loginTokens.fetchToken(user.email).then ->
      user.sentLoginLink = true
