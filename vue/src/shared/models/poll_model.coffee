import BaseModel        from '@/shared/record_store/base_model'
import AppConfig        from '@/shared/services/app_config'
import HasDrafts        from '@/shared/mixins/has_drafts'
import HasDocuments     from '@/shared/mixins/has_documents'
import HasTranslations  from '@/shared/mixins/has_translations'
import HasGuestGroup    from '@/shared/mixins/has_guest_group'
import EventBus         from '@/shared/services/event_bus'
import I18n             from '@/i18n'

export default class PollModel extends BaseModel
  @singular: 'poll'
  @plural: 'polls'
  @indices: ['discussionId', 'authorId', 'latest']
  @draftParent: 'draftParent'
  @draftPayloadAttributes: ['title', 'details']

  afterConstruction: ->
    HasDocuments.apply @, showTitle: true
    HasDrafts.apply @
    HasTranslations.apply @
    HasGuestGroup.apply @

  pollTypeKey: ->
    "poll_types.#{@pollType}"

  draftParent: ->
    @discussion() or @author()

  poll: -> @

  groups: ->
    _.compact [@group(), @discussionGuestGroup(), @guestGroup()]

  # the polls which haven't closed have the highest importance
  # (and so have the lowest value here)
  # Both are sorted by distance from the current time
  # (IE, polls which have closed or will close closest to now are most important)
  importance: (now) ->
    if @closedAt?
      Math.abs(@closedAt - now)
    else
      0.0001 * Math.abs(@closingAt - now)

  defaultValues: ->
    discussionId: null
    title: ''
    details: ''
    detailsFormat: 'html'
    closingAt: moment().add(3, 'days').startOf('hour')
    pollOptionNames: []
    pollOptionIds: []
    customFields: {
      minimum_stance_choices: null
    }
    files: []
    imageFiles: []
    # optionDate: moment().format('YYYY-MM-DD')

  audienceValues: ->
    name: @group().name

  relationships: ->
    @belongsTo 'author', from: 'users'
    @belongsTo 'discussion'
    @belongsTo 'group'
    @belongsTo 'guestGroup', from: 'groups'
    @hasMany   'pollOptions'
    @hasMany   'stances', sortBy: 'createdAt', sortDesc: true
    @hasMany   'pollDidNotVotes'
    @hasMany   'versions', sortBy: 'createdAt'

  authorName: ->
    @author().nameWithTitle(@)

  discussionGuestGroupId: ->
    @discussion().guestGroupId if @discussion()

  discussionGuestGroup: ->
    @discussion().guestGroup() if @discussion()

  groupIds: ->
    _.compact [@groupId, @guestGroupId, @discussionGuestGroupId()]

  reactions: ->
    @recordStore.reactions.find(reactableId: @id, reactableType: "Poll")

  participantIds: ->
    _.map(@latestStances(), 'participantId')

  # who's voted?
  participants: ->
    @recordStore.users.find(@participantIds())

  # who hasn't voted?
  undecided: ->
    if @isActive()
      _.difference(@members(), @participants())
    else
      _.invokeMap @pollDidNotVotes(), 'user'

  membersCount: ->
    # NB: this won't work for people who vote, then leave the group.
    @stancesCount + @undecidedCount

  percentVoted: ->
    return 0 if @membersCount() == 0
    (100 * @stancesCount / (@membersCount())).toFixed(0)

  outcome: ->
    @recordStore.outcomes.find(pollId: @id, latest: true)[0]

  clearStaleStances: ->
    existing = []
    _.each @latestStances('-createdAt'), (stance) ->
      if _.includes(existing, stance.participant())
        stance.latest = false
      else
        existing.push(stance.participant())

  latestStances: (order, limit) ->
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
    @remote.postMember(@key, 'close')

  reopen: =>
    @remote.postMember(@key, 'reopen', poll: {closing_at: @closingAt})

  addOptions: =>
    @remote.postMember(@key, 'add_options', poll_option_names: @pollOptionNames)

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
    @customFields.minimum_stance_choices = _.max [@pollOptionNames.length, 1]

  hasRequiredField: (field) =>
    _.includes AppConfig.pollTemplates[@pollType].required_custom_fields, field

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
    _.each @pollOptions(), (option) =>
      option.remove() unless _.includes(@pollOptionNames, option.name)

  edited: ->
    @versionsCount > 1
