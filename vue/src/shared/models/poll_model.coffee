import BaseModel        from '@/shared/record_store/base_model'
import AppConfig        from '@/shared/services/app_config'
import HasDocuments     from '@/shared/mixins/has_documents'
import HasTranslations  from '@/shared/mixins/has_translations'
import EventBus         from '@/shared/services/event_bus'
import I18n             from '@/i18n'
import { addDays, startOfHour } from 'date-fns'
import { head, sortBy, map, includes, difference, invokeMap, each, max } from 'lodash'

export default class PollModel extends BaseModel
  @singular: 'poll'
  @plural: 'polls'
  @indices: ['discussionId', 'authorId', 'latest']
  @draftParent: 'draftParent'
  @draftPayloadAttributes: ['title', 'details']

  afterConstruction: ->
    HasDocuments.apply @, showTitle: true
    HasTranslations.apply @

  pollTypeKey: ->
    "poll_types.#{@pollType}"

  draftParent: ->
    @discussion() or @author()

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
    @hasMany   'pollOptions'
    @hasMany   'stances', sortBy: 'createdAt', sortDesc: true
    @hasMany   'pollDidNotVotes'
    @hasMany   'versions'

  voters: ->
    @latestStances().map (stance) -> stance.participant()

  members: ->
    @group().members().concat(@voters())

  adminsInclude: (user) ->
    stance = @stanceFor(user)
    @authorIs(user) || (stance && stance.admin) || @group().adminsInclude(user)

  stanceFor: (user) ->
    head sortBy(@recordStore.stances.find(latest: true, pollId: @id, participantId: user.id), 'createdAt')

  authorName: ->
    @author().nameWithTitle(@)

  reactions: ->
    @recordStore.reactions.find(reactableId: @id, reactableType: "Poll")

  participantIds: ->
    map(@latestStances(), 'participantId')

  # who's voted?
  participants: ->
    @recordStore.users.find(@participantIds())

  # who hasn't voted?
  undecided: ->
    if @isActive()
      difference(@members(), @participants())
    else
      invokeMap @pollDidNotVotes(), 'user'

  membersCount: ->
    # NB: this won't work for people who vote, then leave the group.
    @stancesCount + @undecidedCount

  percentVoted: ->
    return 0 if @membersCount() == 0
    (100 * @stancesCount / (@membersCount())).toFixed(0)

  outcome: ->
    @recordStore.outcomes.find(pollId: @id, latest: true)[0]

  createdEvent: ->
    @recordStore.events.find(eventableId: @id, kind: 'poll_created')[0]

  clearStaleStances: ->
    existing = []
    each @latestStances('-createdAt'), (stance) ->
      if includes(existing, stance.participant())
        stance.latest = false
      else
        existing.push(stance.participant())

  latestStances: (order = '-createdAt', limit) ->
    _.slice(_.sortBy(@recordStore.stances.find(pollId: @id, latest: true), order), 0, limit)

  hasDescription: ->
    !!@details

  isActive: ->
    !@closedAt?

  isClosed: ->
    @closedAt?

  goal: ->
    @customFields.goal or @membersCount()

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

  translateOptionName: ->
    AppConfig.pollTemplates[@pollType]['translate_option_name']

  datesAsOptions: ->
    AppConfig.pollTemplates[@pollType]['dates_as_options']

  removeOrphanOptions: ->
    @pollOptions().forEach (option) =>
      option.remove() unless @pollOptionNames.includes(option.name)
