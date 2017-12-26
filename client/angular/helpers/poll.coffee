AppConfig = require 'shared/services/app_config.coffee'
Records   = require 'shared/services/records.coffee'

# A series of helpers for interacting with polls, such as template values for a
# particular poll or getting the last stance from a given user
module.exports =
  fieldFromTemplate: (pollType, field) ->
    fieldFromTemplate(pollType, field)

  iconFor: (poll) ->
    fieldFromTemplate(poll.pollType, 'material_icon')

  myLastStanceFor: (poll) ->
    _.first _.sortBy(Records.stances.find(
      latest: true
      pollId: poll.id
      participantId: AppConfig.currentUserId
    ), 'createdAt')

fieldFromTemplate = (pollType, field) ->
  (AppConfig.pollTemplates[pollType] or {})[field]
