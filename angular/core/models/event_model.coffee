angular.module('loomioApp').factory 'EventModel', (BaseModel) ->
  class EventModel extends BaseModel
    @singular: 'event'
    @plural: 'events'
    @indices: ['id', 'discussionId']

    @eventTypeMap:
      group:              'groups'
      discussion:         'discussions'
      motion:             'proposals'
      comment:            'comments'
      comment_vote:       'comments'
      membership:         'memberships'
      membership_request: 'membershipRequests'

    relationships: ->
      @belongsTo 'actor', from: 'users'
      @belongsTo 'version'
      @hasMany  'notifications'

    delete: ->
      @deleted = true

    actorName: ->
      @actor().name

    model: ->
      @recordStore[@constructor.eventTypeMap[@eventable.type]].find(@eventable.id)

    beforeRemove: ->
      _.invoke(@notifications(), 'remove')
