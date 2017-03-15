angular.module('loomioApp').factory 'Session', ($rootScope, $translate, $window, Records, AppConfig) ->

  login: (data) ->
    Records.import(data)
    return unless AppConfig.currentUserId?

    $translate.use(@user().locale)
    $rootScope.$broadcast 'loggedIn', @user()
    @user()

  logout: ->
    AppConfig.loggingOut = true
    Records.sessions.remote.destroy('').then -> $window.location.href = '/'

  user: ->
    Records.users.find(AppConfig.currentUserId) or Records.users.build()

  visitor: ->
    Records.visitors.find(AppConfig.currentVisitorId)

  currentGroupId: ->
    @currentGroup? && @currentGroup.id
