angular.module('loomioApp').factory 'Session', ($rootScope, $cookies, $translate, $window, Records, AppConfig) ->

  login: (data) ->
    Records.import(data)

    _.merge AppConfig, currentUserId: (data.current_user or {}).id
    return unless AppConfig.currentUserId?

    $translate.use(@user().locale)
    $rootScope.$broadcast 'loggedIn', @user()
    @user()

  logout: ->
    AppConfig.loggingOut = true
    Records.sessions.remote.destroy('').then -> $window.location.href = '/'

  user: ->
    Records.users.find(AppConfig.currentUserId) or Records.users.build(participationToken: $cookies.get('participation_token'))

  currentGroupId: ->
    @currentGroup? && @currentGroup.id
