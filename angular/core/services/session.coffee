angular.module('loomioApp').factory 'Session', ($rootScope, $location, $translate, $window, Records, AppConfig) ->

  login: (data) ->
    Records.import(data)

    defaultParams = _.pick {invitation_token: $location.search().invitation_token}, _.identity
    Records.stances.remote.defaultParams = defaultParams
    Records.polls.remote.defaultParams   = defaultParams

    return unless AppConfig.currentUserId = data.current_user_id
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

  currentGroupId: ->
    @currentGroup? && @currentGroup.id
