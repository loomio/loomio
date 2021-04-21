import BaseModel        from '@/shared/record_store/base_model'
import AppConfig        from '@/shared/services/app_config'
import HasDocuments     from '@/shared/mixins/has_documents'
import HasTranslations  from '@/shared/mixins/has_translations'
import EventBus         from '@/shared/services/event_bus'
import I18n             from '@/i18n'
import NullGroupModel   from '@/shared/models/null_group_model'
import { addDays, startOfHour } from 'date-fns'
import { head, orderBy, map, includes, difference, invokeMap, each, max, slice, sortBy } from 'lodash'

export default class PollModel extends BaseModel
  @singular: 'poll'
  @plural: 'polls'
  @indices: ['discussionId', 'authorId', 'groupId']

  afterConstruction: ->
    HasDocuments.apply @, showTitle: true
    HasTranslations.apply @

  pollTypeKey: ->
    "poll_types.#{@pollType}"

  poll: -> @

  defaultValues: ->
    discussionId: null
    title: ''
    details: '<p></p>'
    detailsFormat: 'html'
    closingAt: startOfHour(addDays(new Date, 3))
    specifiedVotersOnly: false
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
    linkPreviews: []
    notifyOnClosingSoon: 'undecided_voters'
    pleaseShowResults: false
    recipientMessage: null
    recipientAudience: null
    recipientUserIds: []
    recipientEmails: []
    tagIds: []

  audienceValues: ->
    name: @group().name

  relationships: ->
    @belongsTo 'author', from: 'users'
    @belongsTo 'discussion'
    @belongsTo 'group'
    @hasMany   'pollOptions', orderBy: 'priority'
    @hasMany   'stances'
    @hasMany   'versions'

  bestNamedId: ->
    ((@id && @) || (@discusionId && @discussion()) || (@groupId && @group()) || {namedId: ->}).namedId()

  tags: ->
    @recordStore.tags.collection.chain().find(id: {$in: @tagIds}).simplesort('priority').data()

  voters: ->
    @latestStances().map (stance) -> stance.participant()

  members: ->
    ((@group() && @group().members()) || []).concat(@voters())

  adminsInclude: (user) ->
    stance = @stanceFor(user)
    (stance && stance.admin) || (@discussionId && @discussion().adminsInclude(user)) || @group().adminsInclude(user)

  membersInclude: (user) ->
    @stanceFor(user) || (@discussionId && @discussion().membersInclude(user)) || @group().membersInclude(user)

  stanceFor: (user) ->
    head orderBy(@recordStore.stances.find(pollId: @id, participantId: user.id, latest: true, revokedAt: null), 'createdAt', 'desc')

  myStance: ->
    head orderBy(@recordStore.stances.find(pollId: @id, myStance: true, latest: true, revokedAt: null), 'createdAt', 'desc')

  iHaveVoted: ->
    @myStance() && @myStance().castAt

  authorName: ->
    @author().nameWithTitle(@group())

  reactions: ->
    @recordStore.reactions.find(reactableId: @id, reactableType: "Poll")

  decidedVoterIds: ->
    map(@latestCastStances(), 'participantId')

  # who's voted?
  decidedVoters: ->
    @recordStore.users.find(@decidedVoterIds())

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
    slice(sortBy(@recordStore.stances.find(pollId: @id, latest: true, revokedAt: null), order), 0, limit)

  latestCastStances: ->
    @recordStore.stances.collection.chain().find(
      pollId: @id
      latest: true
      revokedAt: null
      castAt: {$ne: null}
    ).data()


  hasDescription: ->
    !!@details

  isActive: ->
    !@discardedAt && !@closedAt?

  isClosed: ->
    @closedAt?

  showResults: ->
    return false if !@closingAt
    return false if @hideResultsUntilClosed && !@closedAt
    @closedAt || (@myStance() || {}).castAt || @pleaseShowResults

  close: =>
    @processing = true
    @remote.postMember(@key, 'close').finally => @processing = false

  reopen: =>
    @processing = true
    @remote.postMember(@key, 'reopen', poll: {closing_at: @closingAt}).finally => @processing = false

  addOptions: =>
    @processing = true
    @remote.postMember(@key, 'add_options', poll_option_names: @pollOptionNames).finally => @processing = false

  addToThread: (discussionId) =>
    @processing = true
    @remote.patchMember(@keyOrId(), 'add_to_thread', { discussion_id: discussionId }).finally => @processing = false

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
    if @pollType == 'poll'
      !@multipleChoice
    else
      AppConfig.pollTemplates[@pollType]['single_choice']

  translateOptionName: ->
    AppConfig.pollTemplates[@pollType]['translate_option_name']

  datesAsOptions: ->
    AppConfig.pollTemplates[@pollType]['dates_as_options']

  removeOrphanOptions: ->
    @pollOptions().forEach (option) =>
      option.remove() unless @pollOptionNames.includes(option.name)
