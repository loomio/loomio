angular.module('loomioApp').factory 'Session', ($rootScope, $translate, $window, Records, AppConfig) ->

  login: (data) ->
    Records.import(data)

    if @visitor()
      defaultParams = {participation_token: @visitor().participationToken}
      Records.stances.remote.defaultParams = defaultParams
      Records.polls.remote.defaultParams   = defaultParams

    return unless AppConfig.currentUserId?
    user = @user()

    $translate.use user.locale
    $rootScope.$broadcast 'loggedIn', user

    if user.timeZone != AppConfig.timeZone
      user.timeZone = AppConfig.timeZone
      Records.users.updateProfile(user)

    user

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
