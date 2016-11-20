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

  homePath: ->
    switch @user().parentGroups().length
      when 0 then '/explore'
      when 1 then '/g/' + @user().parentGroups()[0].key
      else        '/dashboard'

  logout: ->
    AppConfig.loggingOut = true
    Records.sessions.remote.destroy('').then -> $window.location.href = '/'

  user: ->
    Records.users.find(AppConfig.currentUserId) or Records.users.build()

  currentGroupId: ->
    @currentGroup? && @currentGroup.id
