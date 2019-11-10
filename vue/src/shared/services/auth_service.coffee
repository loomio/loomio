import AppConfig from '@/shared/services/app_config'
import Records   from '@/shared/services/records'
import Session from '@/shared/services/session'
import EventBus from '@/shared/services/event_bus'
import Flash from '@/shared/services/flash'
import i18n from '@/i18n.coffee'
import openModal      from '@/shared/helpers/open_modal'

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

  authSuccess: (data) ->
    user = Session.apply(data)
    EventBus.$emit('closeModal')
    Flash.success('auth_form.signed_in')

    if user && !user.hasProfilePhoto() && !user.hasExperienced('changePicture')
      openModal
        component: 'ChangePictureForm'

  signIn: (user = {} , onSuccess = -> , onFailure = ->) ->
    Records.sessions.build(
      _.pick(user, ['email', 'name', 'password', 'code'])
    ).save().then (data) =>
      @authSuccess(data)
      onSuccess(data)
      data
    , (err) ->
      console.log 'error signing in'
      err.json().then (data) ->
        errors = if user.hasToken
          { token: [i18n.t('auth_form.invalid_token')] }
        else
          { password: _.map(data.errors.password, (key) -> i18n.t(key)) }
        user.update(errors: errors)

  signUp: (user, onSuccess = -> , onFailure = -> ) ->
    Records.registrations.build(
      _.pick(user, ['email', 'name', 'recaptcha', 'legalAccepted'])
    ).save().then (data) =>
      if user.hasToken or data.signed_in
        @authSuccess(data)
        onSuccess(data)
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
      user.errors.name = [i18n.t('auth_form.name_required')]

    if AppConfig.theme.terms_url && !vars.legalAccepted
      user.errors.legalAccepted = [i18n.t('auth_form.terms_required')]

    if _.keys(user.errors)
      user.name           = vars.name
      user.legalAccepted  = vars.legalAccepted

    return _.keys(user.errors).length == 0
