angular.module('loomioApp').factory 'EventModel', (BaseModel) ->
  class EventModel extends BaseModel
    @singular: 'event'
    @plural: 'events'
    @indices: ['id', 'discussionId']

    @eventTypeMap: {
      'user_added_to_group':            'group',
      'membership_request_approved':    'group',
      'membership_requested':           'membershipRequest',
      'new_discussion':                 'discussion',
      'discussion_edited':              'discussion',
      'new_motion':                     'proposal',
      'motion_closed':                  'proposal',
      'motion_closed_by_user':          'proposal',
      'motion_edited':                  'proposal',
      'new_vote':                       'proposal',
      'motion_closing_soon':            'proposal',
      'motion_outcome_created':         'proposal',
      'new_comment':                    'comment',
      'comment_liked':                  'comment',
      'comment_replied_to':             'comment',
      'user_mentioned':                 'comment'
    }

    relationships: ->
      @belongsTo 'membership'
      @belongsTo 'membershipRequest'
      @belongsTo 'discussion'
      @belongsTo 'comment'
      @belongsTo 'proposal'
      @belongsTo 'vote'
      @belongsTo 'actor', from: 'users'
      @belongsTo 'version'

    group: ->
      return @membership().group()        if @membership()
      return @membershipRequest().group() if @membershipRequest()
      return @discussion.group()          if @discussion()

    delete: ->
      @deleted = true

    actorName: ->
      @actor().name

    relevantRecordType: ->
      @constructor.eventTypeMap[@kind]

    relevantRecord: ->
      @[@relevantRecordType()]()
