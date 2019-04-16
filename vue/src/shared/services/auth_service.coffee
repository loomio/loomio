import AppConfig from '@/shared/services/app_config'
import Records   from '@/shared/services/records'

export default new class AuthService
  emailStatus: (user) ->
    pendingToken = (AppConfig.pendingIdentity or {}).token
    Records.users.emailStatus(user.email, pendingToken).then (data) =>
      @applyEmailStatus(user, _.head(data.users))

  applyEmailStatus: (user, data = {}) ->
    keys = ['name', 'email', 'avatar_kind', 'avatar_initials', 'email_hash',
            'avatar_url', 'has_password', 'email_status', 'email_verified',
            'legal_accepted_at', 'auth_form']
    user.update _.pickBy(_.mapKeys(_.pick(data, keys), (v,k) -> _.camelCase(k)), _.identity)
    user.update(hasToken: data.has_token)
    user

  signIn: (user = {}, onSuccess, finished) ->
    Records.sessions.build(
      _.pick(user, ['email', 'name', 'password'])
    ).save().then ->
      onSuccess()
    , (response) ->
      response.json().then (data) ->
        user.errors = if user.hasToken
          { token:    [I18n.t('auth_form.invalid_token')] }
        else
          { password: _.map(data.errors.password, (key) -> I18n.t(key)) }
        finished()

  signUp: (user, onSuccess) ->
    Records.registrations.build(
      _.pick(user, ['email', 'name', 'recaptcha', 'legalAccepted'])
    ).save().then (data) ->
      if user.hasToken or data.signed_in
        onSuccess()
      else
        user.update({sentLoginLink: true})
      data

  reactivate: (user) ->
    Records.users.reactivate(user).then ->
      user.update({sentLoginLink: true})

  sendLoginLink: (user) ->
    Records.loginTokens.fetchToken(user.email).then ->
      user.update({sentLoginLink: true})

  validSignup: (vars, user) ->
    user.errors = {}

    if !vars.name
      user.errors.name = [I18n.t('auth_form.name_required')]

    if AppConfig.theme.terms_url && !vars.legalAccepted
      user.errors.legalAccepted = [I18n.t('auth_form.terms_required')]

    if _.keys(user.errors)
      user.name           = vars.name
      user.legalAccepted  = vars.legalAccepted

    return _.keys(user.errors).length == 0
