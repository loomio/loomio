angular.module('loomioApp').factory 'EventModel', (BaseModel) ->
  class EventModel extends BaseModel
    @singular: 'event'
    @plural: 'events'
    @indices: ['id', 'discussionId']

    @eventTypeMap:
      group:              'groups'
      discussion:         'discussions'
      poll:               'polls'
      outcome:            'outcomes'
      stance:             'stances'
      comment:            'comments'
      comment_vote:       'comments'
      membership:         'memberships'
      membership_request: 'membershipRequests'

    relationships: ->
      @belongsTo 'actor', from: 'users'
      @belongsTo 'version'
      @hasMany  'notifications'

    discussion: ->
      @recordStore.discussions.find(@discussionId)

    translateKey: ->
      if @kind == 'new_comment' and @model().parentId?
        'comment_replied_to'
      else
        @kind

    delete: ->
      @deleted = true

    actorName: ->
      @actor().name if @actor()

    isPollEvent: ->
      _.contains ['poll', 'outcome'], @eventable.type

    title: ->
      switch @eventable.type
        when 'comment'             then (@model().parent().authorName() if @model().parent())
        when 'discussion'          then @model().title
        when 'poll', 'outcome'     then @model().poll().title
        when 'group', 'membership' then @model().group().name

    isLastRead: ->
      @discussion() &&
      @discussion().isUnread() &&
      @discussion().lastReadSequenceId == @sequenceId

    model: ->
      @recordStore[@constructor.eventTypeMap[@eventable.type]].find(@eventable.id)

    beforeRemove: ->
      _.invoke(@notifications(), 'remove')
