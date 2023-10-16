import BaseModel        from '@/shared/record_store/base_model'
import AppConfig        from '@/shared/services/app_config'
import Session          from '@/shared/services/session'
import { pick }            from 'lodash'
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
    anonymous: false
    groupId: null
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
    reasonPrompt: null
    processName: null
    processSubtitle: null
    processIntroduction: null
    processIntroductionFormat: 'html'
    processUrl: null
    pollOptions: []
    pollOptionNameFormat: 'plain'
    shuffleOptions: false
    hideResults: 'off'
    position: 0

  relationships: ->
    @belongsTo 'author', from: 'users'
    @belongsTo 'group'

  buildPoll: ->
    poll = @recordStore.polls.build()

    attrs = pick(@, Object.keys(@defaultValues()))
    attrs.pollTemplateId = @id
    attrs.pollTemplateKey = @key
    attrs.authorId = Session.user().id
    attrs.closingAt = startOfHour(addDays(new Date(), @defaultDurationInDays))
    attrs.pollOptionsAttributes = @pollOptionsAttributes()

    poll.update(attrs)
    poll

  pollOptionsAttributes: ->
    @pollOptions.map (o) ->
      name: o.name
      meaning: o.meaning
      prompt: o.prompt
      icon: o.icon


