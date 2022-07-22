import BaseModel        from '@/shared/record_store/base_model'
import AppConfig        from '@/shared/services/app_config'
import Session          from '@/shared/services/session'
import HasDocuments     from '@/shared/mixins/has_documents'
import HasTranslations  from '@/shared/mixins/has_translations'
import EventBus         from '@/shared/services/event_bus'
import I18n             from '@/i18n'
import NullGroupModel   from '@/shared/models/null_group_model'
import { addDays, startOfHour, differenceInHours, addHours } from 'date-fns'
import { snakeCase, camelCase, compact, head, orderBy, sortBy, map, includes, difference, invokeMap, each, max, flatten, slice, uniq, isEqual, shuffle } from 'lodash'

export default class PollModel extends BaseModel
  @singular: 'poll'
  @plural: 'polls'
  @uniqueIndices: ['id', 'key']
  @indices: ['discussionId', 'authorId', 'groupId']

  afterConstruction: ->
    HasDocuments.apply @, showTitle: true
    HasTranslations.apply @

  config: ->
    AppConfig.pollTypes[@pollType]

  i18n: ->
    AppConfig.pollTypes[@pollType].i18n

  pollTypeKey: ->
    "poll_types.#{@pollType}"

  poll: -> @

  defaultValues: ->
    # read defaults based on pollType and apply them
    discussionId: null
    title: ''
    closingAt: null
    details: ''
    detailsFormat: 'html'
    decidedVotersCount: 0
    durationInDays: null
    specifiedVotersOnly: false
    pollOptionNames: []
    pollType: 'single_choice'
    chartColumn: null
    chartType: null
    iconType: null
    minScore: null
    maxScore: null
    minimumStanceChoices: null
    maximumStanceChoices: null
    dotsPerPerson: null
    canRespondMaybe: true
    meetingDuration: null
    limitReasonLength: true
    stanceReasonRequired: 'optional'
    files: []
    imageFiles: []
    attachments: []
    linkPreviews: []
    notifyOnClosingSoon: 'undecided_voters'
    results: []
    pollOptionIds: []
    processName: null
    processSubtitle: null
    processDescription: null
    processDescriptionFormat: 'html'
    pollOptionNameFormat: null
    recipientMessage: null
    recipientAudience: null
    recipientUserIds: []
    recipientChatbotIds: []
    recipientEmails: []
    notifyRecipients: true
    shuffleOptions: false
    template: false
    tagIds: []
    hideResults: 'off'
    stanceCounts: []

  cloneTemplate: ->
    clone = @clone()
    clone.id = null
    clone.key = null
    clone.sourceTemplateId = @id
    clone.authorId = Session.user().id
    clone.groupId = null
    clone.discussionId = null

    #use durationInDays
    if @closingAt
      clone.closingAt = startOfHour(addHours(new Date(), differenceInHours(@closingAt, @createdAt)))
    clone.closedAt = null
    clone.createdAt = null
    clone.updatedAt = null
    clone.decidedVotersCount = null
    clone.undecidedVotersCount = null
    clone.template = !@template
    clone

  applyPollTypeDefaults: ->
    map AppConfig.pollTypes[@pollType].defaults, (value, key) =>
      @[camelCase(key)] = value

  setClosingAt: ->
    @closingAt = startOfHour(addDays(new Date(), @durationInDays))

  defaulted: (attr) ->
    if @[attr] == null
      AppConfig.pollTypes[@pollType].defaults[snakeCase(attr)]
    else
      @[attr]

  audienceValues: ->
    name: @group().name

  relationships: ->
    @belongsTo 'author', from: 'users'
    @belongsTo 'discussion'
    @belongsTo 'group'
    @hasMany   'stances'
    @hasMany   'versions'

  pollOptions: ->
    options = (@recordStore.pollOptions.collection.chain().find(pollId: @id, id: {$in: @pollOptionIds}).data())
    orderBy(options, 'priority')

  pollOptionsForVoting: ->
    if @shuffleOptions
      shuffle(@pollOptions())
    else
      @pollOptions()

  bestNamedId: ->
    ((@id && @) || (@discusionId && @discussion()) || (@groupId && @group()) || {namedId: ->}).namedId()

  tags: ->
    @recordStore.tags.collection.chain().find(id: {$in: @tagIds}).simplesort('priority').data()

  voters: ->
    @latestStances().map (stance) -> stance.participant()

  members: ->
    ((@group() && @group().members()) || []).concat(@voters())

  participantIds: ->
    compact flatten(
      [@authorId],
      map(@stances(), 'participantId')
    )

  adminsInclude: (user) ->
    stance = @stanceFor(user)
    (@authorId == user.id && (!@groupId || @group().membersInclude(user))) ||
    (stance && stance.admin) || 
    (@discussionId && @discussion().adminsInclude(user)) || 
    @group().adminsInclude(user)

  votersInclude: (user) ->
    if specifiedVotersOnly
      @stanceFor(user)
    else
      @membersInclude(user)

  membersInclude: (user) ->
    @stanceFor(user) || (@discussionId && @discussion().membersInclude(user)) || @group().membersInclude(user)

  stanceFor: (user) ->
    if user.id == AppConfig.currentUserId
      @myStance() 
    else
      head orderBy(@recordStore.stances.find(pollId: @id, participantId: user.id, latest: true, revokedAt: null), 'createdAt', 'desc')

  myStance: ->
    @recordStore.stances.find(id: @myStanceId, revokedAt: null)[0]

  iHaveVoted: ->
    @myStanceId && @myStance() && @myStance().castAt

  showResults: ->
    !!@closingAt &&
    switch @hideResults
      when "until_closed"
        @closedAt
      when "until_vote"
        @closedAt || @iHaveVoted()
      else
        true

  optionsDiffer: (options) ->
    !isEqual(sortBy(@pollOptionNames), sortBy(map(options, 'name')))

  iCanVote: ->
    @isActive() &&
    (@anyoneCanParticipate or @myStance() or (!@specifiedVotersOnly and @membersInclude(Session.user())))

  isBlank: ->
    @details == '' or @details == null or @details == '<p></p>'

  authorName: ->
    @author().nameWithTitle(@group())

  reactions: ->
    @recordStore.reactions.find(reactableId: @id, reactableType: "Poll")

  decidedVoterIds: ->
    uniq flatten @results.map((o) -> o.voter_ids)

  # who's voted?
  decidedVoters: ->
    @recordStore.users.find(@decidedVoterIds())

  outcome: ->
    @recordStore.outcomes.find(pollId: @id, latest: true)[0]

  createdEvent: ->
    @recordStore.events.find(eventableId: @id, kind: 'poll_created')[0]

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

  close: =>
    @processing = true
    @remote.postMember(@key, 'close')
    .finally => @processing = false

  reopen: =>
    @processing = true
    @remote.postMember(@key, 'reopen', poll: {closing_at: @closingAt})
    .finally => @processing = false

  addToThread: (discussionId) =>
    @processing = true
    @remote.patchMember(@keyOrId(), 'add_to_thread', { discussion_id: discussionId })
    .finally => @processing = false

  notifyAction: ->
    if @isNew()
      'publish'
    else
      'edit'

  translatedPollType: ->
    @processName || I18n.t("poll_types.#{@pollType}")

  translatedPollTypeCaps: ->
    @processName || I18n.t("decision_tools_card.#{@pollType}_title")

  addOption: (option) =>
    return false if @pollOptionNames.includes(option) or !option
    @pollOptionNames.push option
    @pollOptionNames.sort() if @pollType == "meeting"
    option

  hasVariableScore: -> 
    @defaulted('minScore') != @defaulted('maxScore')

  singleChoice: ->
    @defaulted('minimumStanceChoices') == @defaulted('maximumStanceChoices') == 1

  datesAsOptions: ->
    @config().poll_option_name_format == 'iso8601'

  removeOrphanOptions: ->
    @pollOptions().forEach (option) =>
      option.remove() unless @pollOptionNames.includes(option.name)
