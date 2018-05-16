AppConfig = require 'shared/services/app_config'
Records   = require 'shared/services/records'

{ hardReload } = require 'shared/helpers/window'

module.exports = new class AuthService

  emailStatus: (user) ->
    pendingToken = (AppConfig.pendingIdentity or {}).token
    Records.users.emailStatus(user.email, pendingToken).then (data) =>
      @applyEmailStatus(user, _.first(data.users))

  applyEmailStatus: (user, data = {}) ->
    keys = ['name', 'email', 'avatar_kind', 'avatar_initials', 'email_hash', 'avatar_url', 'has_password', 'email_status', 'legal_accepted_at']
    user.update _.pick(_.mapKeys(_.pick(data, keys), (v,k) -> _.camelCase(k)), _.identity)
    user.update(hasToken: data.has_token)
    user

  signUpOrIn: (user) ->
    if user.emailStatus == 'unused'
      @signUp(user)
    else
      @signIn(user)

  signIn: (user = {}) ->
    Records.sessions.build
      name: user.name
      email: user.email
      password: user.password
      legalAccepted: user.legalAccepted
    .save().then ->
      hardReload()
    , () ->
      user.errors = if user.hasToken
        { token:    [I18n.t('auth_form.invalid_token')] }
      else
        { password: [I18n.t('auth_form.invalid_password')] }

  signUp: (user) ->
    Records.registrations.build(
      _.pick(user, ['email', 'name', 'recaptcha', 'legalAccepted'])
    ).save().then (data) ->
      if user.hasToken or data.signed_in
        hardReload()
      else
        user.sentLoginLink = true
      data

  reactivate: (user) ->
    Records.users.reactivate(user).then ->
      user.sentLoginLink = true

  sendLoginLink: (user) ->
    Records.loginTokens.fetchToken(user.email).then ->
      user.sentLoginLink = true
