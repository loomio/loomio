AppConfig = require 'shared/services/app_config.coffee'
Records   = require 'shared/interfaces/records.coffee'

module.exports = ->
  login: (data, invitationToken) ->
    Records.import(data)

    defaultParams = _.pick {invitation_token: invtationToken}, _.identity
    Records.stances.remote.defaultParams = defaultParams
    Records.polls.remote.defaultParams   = defaultParams

    return unless AppConfig.currentUserId = data.current_user_id
    user = @user()

    @setLocale(user.locale)

    if user.timeZone != AppConfig.timeZone
      user.timeZone = AppConfig.timeZone
      Records.users.updateProfile(user)

    user

  logout: ->
    AppConfig.loggingOut = true
    Records.sessions.remote.destroy('').then -> window.location.href = '/'

  user: ->
    Records.users.find(AppConfig.currentUserId) or Records.users.build()

  currentGroupId: ->
    @currentGroup? && @currentGroup.id
