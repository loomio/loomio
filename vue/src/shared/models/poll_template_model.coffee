import BaseModel        from '@/shared/record_store/base_model'
import AppConfig        from '@/shared/services/app_config'
import Session          from '@/shared/services/session'
import {map, camelCase, cloneDeep }            from 'lodash'
import I18n             from '@/i18n'
import { startOfHour, addDays } from 'date-fns'

export default class PollTemplateModel extends BaseModel
  @singular: 'pollTemplate'
  @plural: 'pollTemplates'
  @uniqueIndices: ['id', 'key']
  @indices: ['groupId']

  config: ->
    AppConfig.pollTypes[@pollType]

  defaultValues: ->
    title: ''
    details: ''
    detailsFormat: 'html'
    defaultDurationInDays: null
    specifiedVotersOnly: false
    pollType: null
    chartColumn: null
    chartType: null
    minScore: null
    maxScore: null
    minimumStanceChoices: null
    maximumStanceChoices: null
    dotsPerPerson: null
    canRespondMaybe: true
    meetingDuration: null
    limitReasonLength: true
    stanceReasonRequired: 'optional'
    tags: []
    files: []
    imageFiles: []
    attachments: []
    linkPreviews: []
    notifyOnClosingSoon: 'undecided_voters'
    processName: null
    processSubtitle: null
    processUrl: null
    pollOptions: []
    pollOptionNameFormat: 'plain'
    shuffleOptions: false
    hideResults: 'off'

  relationships: ->
    @belongsTo 'author', from: 'users'
    @belongsTo 'group'

  applyPollTypeDefaults: ->
    map AppConfig.pollTypes[@pollType].defaults, (value, key) =>
      if key.match(/_i18n$/)
        @[camelCase(key.replace('_i18n', ''))] = I18n.t(value)
      else
        @[camelCase(key)] = value

    common_poll_options = AppConfig.pollTypes[@pollType].common_poll_options || []

    @pollOptions = common_poll_options.filter((o) -> o.default).map (o) =>
        name:  I18n.t(o.name_i18n)
        meaning: I18n.t(o.meaning_i18n)
        prompt: I18n.t(o.prompt_i18n)
        icon: o.icon

  buildPoll: ->
    poll = @recordStore.polls.build()

    Object.keys(@defaultValues()).forEach (attr) =>
      poll[attr] = @[attr]
      
    poll.authorId = Session.user().id
    poll.closingAt = startOfHour(addDays(new Date(), @defaultDurationInDays))
    poll.pollOptionsAttributes = cloneDeep @pollOptions
    poll


