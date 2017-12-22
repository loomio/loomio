AppConfig = require 'shared/services/app_config.coffee'

angular.module('loomioApp').factory 'Session', ($rootScope, $location, $translate, $window, Records) ->

  login: (data) ->
    Records.import(data)

    defaultParams = _.pick {invitation_token: $location.search().invitation_token}, _.identity
    Records.stances.remote.defaultParams = defaultParams
    Records.polls.remote.defaultParams   = defaultParams

    return unless AppConfig.currentUserId = data.current_user_id
    user = @user()

    @setLocale(user.locale)
    $rootScope.$broadcast 'loggedIn', user

    if user.timeZone != AppConfig.timeZone
      user.timeZone = AppConfig.timeZone
      Records.users.updateProfile(user)

    user

  setLocale: (locale) ->
    $translate.use(locale)
    lc_locale = locale.toLowerCase().replace('_','-')
    return if lc_locale == "en"
    fetch("#{Loomio.assetRoot}/moment_locales/#{lc_locale}.js").then((resp) -> resp.text()).then (data) ->
      eval(data)
      moment.locale(lc_locale)

  logout: ->
    AppConfig.loggingOut = true
    Records.sessions.remote.destroy('').then -> $window.location.href = '/'

  user: ->
    Records.users.find(AppConfig.currentUserId) or Records.users.build()

  currentGroupId: ->
    @currentGroup? && @currentGroup.id
