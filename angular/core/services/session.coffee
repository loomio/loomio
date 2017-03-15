angular.module('loomioApp').factory 'Session', ($rootScope, $translate, $window, Records, AppConfig) ->

  login: (data) ->
    Records.import(data)
    return unless AppConfig.currentUserId?

    $translate.use(@user().locale)
    $rootScope.$broadcast 'loggedIn', @user()

    if @visitor()
      Records.stances.remote.defaultParams =
        participation_token: @visitor().participationToken
      Records.polls.remote.defaultParams =
        participation_token: @visitor().participationToken

    @user()

  logout: ->
    AppConfig.loggingOut = true
    Records.sessions.remote.destroy('').then -> $window.location.href = '/'

  user: ->
    Records.users.find(AppConfig.currentUserId) or Records.users.build()

  visitor: ->
    Records.visitors.find(AppConfig.currentVisitorId)

  participant: ->
    @visitor() or @user()

  currentGroupId: ->
    @currentGroup? && @currentGroup.id
