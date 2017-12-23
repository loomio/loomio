AppConfig = require 'shared/services/app_config.coffee'
Records   = require 'shared/services/records.coffee'

module.exports = new class Session
  signIn: (data, invitationToken) ->
    Records.import(data)

    defaultParams = _.pick {invitation_token: invitationToken}, _.identity
    Records.stances.remote.defaultParams = defaultParams
    Records.polls.remote.defaultParams   = defaultParams

    return unless AppConfig.currentUserId = data.current_user_id
    user = @user()

    if user.timeZone != AppConfig.timeZone
      user.timeZone = AppConfig.timeZone
      Records.users.updateProfile(user)

    user

  signOut: ->
    AppConfig.loggingOut = true
    Records.sessions.remote.destroy('').then -> window.location.href = '/'

  user: ->
    Records.users.find(AppConfig.currentUserId) or Records.users.build()

  currentGroupId: ->
    @currentGroup? && @currentGroup.id
