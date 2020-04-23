import BaseModel        from '@/shared/record_store/base_model'
import AppConfig        from '@/shared/services/app_config'
import HasDocuments     from '@/shared/mixins/has_documents'
import HasTranslations  from '@/shared/mixins/has_translations'
import EventBus         from '@/shared/services/event_bus'
import I18n             from '@/i18n'
import { addDays, startOfHour } from 'date-fns'
import { head, orderBy, map, includes, difference, invokeMap, each, max, slice, sortBy } from 'lodash-es'

export default class PollModel extends BaseModel
  @singular: 'poll'
  @plural: 'polls'
  @indices: ['discussionId', 'authorId', 'latest']

  afterConstruction: ->
    HasDocuments.apply @, showTitle: true
    HasTranslations.apply @

  pollTypeKey: ->
    "poll_types.#{@pollType}"

  poll: -> @

  defaultValues: ->
    discussionId: null
    title: ''
    details: ''
    detailsFormat: 'html'
    closingAt: startOfHour(addDays(new Date, 3))
    pollOptionNames: []
    pollOptionIds: []
    customFields: {
      minimum_stance_choices: null
      max_score: null
      min_score: null
    }
    files: []
    imageFiles: []
    attachments: []

  audienceValues: ->
    name: @group().name

  relationships: ->
    @belongsTo 'author', from: 'users'
    @belongsTo 'discussion'
    @belongsTo 'group'
    @hasMany   'pollOptions', orderBy: 'priority'
    @hasMany   'stances'
    @hasMany   'versions'

  voters: ->
    @latestStances().map (stance) -> stance.participant()

  members: ->
    ((@group() && @group().members()) || []).concat(@voters())

  adminsInclude: (user) ->
    stance = @stanceFor(user)
    @authorIs(user) || (stance && stance.admin) || @group().adminsInclude(user)

  membersInclude: (user) ->
    @stanceFor(user) || @group().membersInclude(user)

  stanceFor: (user) ->
    head orderBy(@recordStore.stances.find(latest: true, pollId: @id, participantId: user.id), 'createdAt', 'desc')

  authorName: ->
    @author().nameWithTitle(@)

  reactions: ->
    @recordStore.reactions.find(reactableId: @id, reactableType: "Poll")

  participantIds: ->
    map(@latestStances(), 'participantId')

  # who's voted?
  participants: ->
    @recordStore.users.find(@participantIds())

  membersCount: ->
    # NB: this won't work for people who vote, then leave the group.
    @stancesCount + @undecidedCount

  outcome: ->
    @recordStore.outcomes.find(pollId: @id, latest: true)[0]

  createdEvent: ->
    @recordStore.events.find(eventableId: @id, kind: 'poll_created')[0]

  clearStaleStances: ->
    existing = []
    each @latestStances(), (stance) ->
      if includes(existing, stance.participantId)
        stance.latest = false
      else
        existing.push(stance.participantId)

  latestStances: (order = '-createdAt', limit) ->
    slice(sortBy(@recordStore.stances.find(pollId: @id, latest: true), order), 0, limit)

  hasDescription: ->
    !!@details

  isActive: ->
    !@closedAt?

  isClosed: ->
    @closedAt?

  close: =>
    @processing = true
    @remote.postMember(@key, 'close').finally => @processing = false

  reopen: =>
    @processing = true
    @remote.postMember(@key, 'reopen', poll: {closing_at: @closingAt}).finally => @processing = false

  addOptions: =>
    @processing = true
    @remote.postMember(@key, 'add_options', poll_option_names: @pollOptionNames).finally => @processing = false

  toggleSubscription: =>
    @remote.postMember(@key, 'toggle_subscription')

  notifyAction: ->
    if @isNew()
      'publish'
    else
      'edit'

  translatedPollType: ->
    I18n.t("poll_types.#{@pollType}")

  addOption: (option) =>
    return false if @pollOptionNames.includes(option) or !option
    @pollOptionNames.push option
    @pollOptionNames.sort() if @pollType == "meeting"
    option

  setMinimumStanceChoices: =>
    return unless @isNew() and @hasRequiredField('minimum_stance_choices')
    @customFields.minimum_stance_choices = max [@pollOptionNames.length, 1]

  hasRequiredField: (field) =>
    includes AppConfig.pollTemplates[@pollType].required_custom_fields, field

  hasPollSetting: (setting) =>
    AppConfig.pollTemplates[@pollType][setting]?

  hasVariableScore: ->
    AppConfig.pollTemplates[@pollType]['has_variable_score']

  hasOptionIcons: ->
    AppConfig.pollTemplates[@pollType]['has_option_icons']

  singleChoice: ->
    AppConfig.pollTemplates[@pollType]['single_choice']

  translateOptionName: ->
    AppConfig.pollTemplates[@pollType]['translate_option_name']

  datesAsOptions: ->
    AppConfig.pollTemplates[@pollType]['dates_as_options']

  removeOrphanOptions: ->
    @pollOptions().forEach (option) =>
      option.remove() unless @pollOptionNames.includes(option.name)
