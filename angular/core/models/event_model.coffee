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
      version:            'versions'
      stance:             'stances'
      comment:            'comments'
      comment_vote:       'comments'
      membership:         'memberships'
      membership_request: 'membershipRequests'

    relationships: ->
      @belongsTo 'parent', from: 'events'
      @belongsTo 'actor', from: 'users'
      @belongsTo 'discussion'
      @belongsTo 'version'
      @hasMany  'notifications'

    children: ->
      @recordStore.events.find(parentId: @id)

    delete: ->
      @deleted = true

    actorName: ->
      @actor().name if @actor()

    actorUsername: ->
      @actor().username if @actor()

    model: ->
      @recordStore[@constructor.eventTypeMap[@eventable.type]].find(@eventable.id)

    isUnread: ->
      !@discussion().hasRead(@sequenceId)

    markAsRead: ->
      @discussion().markAsRead(@sequenceId)

    beforeRemove: ->
      _.invoke(@notifications(), 'remove')

    next: ->
      @recordStore.events.find(parentId: @parentId, position: @position + 1)[0]

    previous: ->
      @recordStore.events.find(parentId: @parentId, position: @position - 1)[0]
