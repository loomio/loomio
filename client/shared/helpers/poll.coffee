AppConfig     = require 'shared/services/app_config'
Records       = require 'shared/services/records'

# A series of helpers for interacting with polls, such as template values for a
# particular poll or getting the last stance from a given user
module.exports =
  fieldFromTemplate: (pollType, field) ->
    fieldFromTemplate(pollType, field)

  iconFor: (poll) ->
    fieldFromTemplate(poll.pollType, 'material_icon')

  settingsFor: (poll) ->
    _.compact [
      ('multipleChoice'        if poll.pollType == 'poll'),
      'notifyOnParticipate',
      ('canRespondMaybe'       if poll.pollType == 'meeting' && poll.isNew()),
      ('anonymous'             if !fieldFromTemplate(poll.pollType, 'prevent_anonymous')),
      ('deanonymizeAfterClose' if poll.anonymous),
      ('voterCanAddOptions'   if fieldFromTemplate(poll.pollType, 'can_add_options'))
    ]

  myLastStanceFor: (poll) ->
    _.first _.sortBy(Records.stances.find(
      latest: true
      pollId: poll.id
      participantId: AppConfig.currentUserId
    ), 'createdAt')

fieldFromTemplate = (pollType, field) ->
  (AppConfig.pollTemplates[pollType] or {})[field]
