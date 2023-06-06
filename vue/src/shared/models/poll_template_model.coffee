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
    defaultDurationInDays: 7
    specifiedVotersOnly: false
    pollType: null
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

  buildPoll: ->
    poll = @recordStore.polls.build()

    Object.keys(@defaultValues()).forEach (attr) =>
      poll[attr] = @[attr]
      
    poll.authorId = Session.user().id
    poll.closingAt = startOfHour(addDays(new Date(), @defaultDurationInDays))
    poll.pollOptionsAttributes = @pollOptions.map (o) ->
      name: o.name
      meaning: o.meaning
      prompt: o.prompt
      icon: o.icon
    poll


