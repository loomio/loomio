AppConfig = require 'shared/services/app_config.coffee'
Session   = require 'shared/services/session.coffee'

{ hardReload } = require 'angular/helpers/window.coffee'

module.exports =
  signIn: (data, $location, $rootScope, $translate) =>
    Session.signIn(data, $location.search().invitation_token)
    $rootScope.$broadcast 'loggedIn', Session.user()

  signOut: ->
    AppConfig.loggingOut = true
    Records.sessions.remote.destroy('').then -> hardReload('/')

  setLocale: ($translate) ->
    locale = Session.user().locale.toLowerCase().replace('_','-')
    $translate.use(locale)
    return if locale == "en"
    fetch("#{AppConfig.assetRoot}/moment_locales/#{locale}.js").then((resp) -> resp.text()).then (data) ->
      eval(data)
      moment.locale(locale)
