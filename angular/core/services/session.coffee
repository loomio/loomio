angular.module('loomioApp').factory 'Session', ($rootScope, $translate, $window, Records, AppConfig) ->

  login: (data) ->
    return unless data.current_user and data.current_user.id
    data.users = data.users || []
    data.users.push(data.current_user)
    Records.import(data)

    _.merge AppConfig, currentUserId: data.current_user.id

    $translate.use(@user().locale)
    $rootScope.$broadcast 'loggedIn', @user()
    @user()

  logout: ->
    AppConfig.loggingOut = true
    Records.sessions.remote.destroy('').then -> $window.location.href = '/'

  user: ->
    Records.users.find(AppConfig.currentUserId) or Records.users.build()

  currentGroupId: ->
    @currentGroup? && @currentGroup.id
