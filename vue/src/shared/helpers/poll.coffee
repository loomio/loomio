import AppConfig from '@/shared/services/app_config'
import Records   from '@/shared/services/records'
import i18n from '@/i18n.coffee'

# A series of helpers for interacting with polls, such as template values for a
# particular poll or getting the last stance from a given user
export fieldFromTemplate = (pollType, field) ->
  (AppConfig.pollTemplates[pollType] or {})[field]

export iconFor = (poll) ->
  fieldFromTemplate(poll.pollType, 'material_icon')

export settingsFor = (poll) ->
  _.compact [
    ('multipleChoice'        if poll.pollType == 'poll'),
    'notifyOnParticipate',
    ('canRespondMaybe'       if poll.pollType == 'meeting' && poll.isNew()),
    ('anonymous'             if !fieldFromTemplate(poll.pollType, 'prevent_anonymous')),
    ('deanonymizeAfterClose' if poll.anonymous),
    ('voterCanAddOptions'    if fieldFromTemplate(poll.pollType, 'can_add_options'))
  ]

export myLastStanceFor = (poll) ->
  _.head _.sortBy(Records.stances.find(
    latest: true
    pollId: poll.id
    participantId: AppConfig.currentUserId
  ), 'createdAt')

export participantName = (stance) ->
  if stance.participant()
    stance.participant().nameWithTitle(stance.poll())
  else
    i18n.t('common.anonymous')
