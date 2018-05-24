AppConfig = require 'shared/services/app_config'
Records   = require 'shared/services/records'
I18n      = require 'shared/services/i18n'

module.exports = new class AuthService

  emailStatus: (user) ->
    pendingToken = (AppConfig.pendingIdentity or {}).token
    Records.users.emailStatus(user.email, pendingToken).then (data) =>
      @applyEmailStatus(user, _.first(data.users))

  applyEmailStatus: (user, data = {}) ->
    keys = ['name', 'email', 'avatar_kind', 'avatar_initials', 'email_hash',
            'avatar_url', 'has_password', 'email_status', 'email_verified',
            'legal_accepted_at', 'auth_form']
    user.update _.pick(_.mapKeys(_.pick(data, keys), (v,k) -> _.camelCase(k)), _.identity)
    user.update(hasToken: data.has_token)
    user

  signIn: (user = {}, onSuccess) ->
    Records.sessions.build(
      _.pick(user, ['email', 'name', 'password'])
    ).save().then ->
      onSuccess()
    , () ->
      user.errors = if user.hasToken
        { token:    [I18n.t('auth_form.invalid_token')] }
      else
        { password: [I18n.t('auth_form.invalid_password')] }

  signUp: (user, onSuccess) ->
    Records.registrations.build(
      _.pick(user, ['email', 'name', 'recaptcha', 'legalAccepted'])
    ).save().then (data) ->
      if user.hasToken or data.signed_in
        onSuccess()
      else
        user.sentLoginLink = true
      data

  reactivate: (user) ->
    Records.users.reactivate(user).then ->
      user.sentLoginLink = true

  sendLoginLink: (user) ->
    Records.loginTokens.fetchToken(user.email).then ->
      user.sentLoginLink = true

  validSignup: (vars, user) ->
    user.errors = {}

    if !vars.name
      user.errors.name = [I18n.t('auth_form.name_required')]

    if AppConfig.theme.terms_url && !vars.legalAccepted
      user.errors.legalAccepted = [I18n.t('auth_form.terms_required')]

    if _.keys(user.errors)
      user.name           = vars.name
      user.legalAccepted  = vars.legalAccepted
