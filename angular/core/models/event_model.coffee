angular.module('loomioApp').factory 'EventModel', (BaseModel) ->
  class EventModel extends BaseModel
    @singular: 'event'
    @plural: 'events'
    @indices: ['id', 'discussionId']

    @eventTypeMap: {
      'user_added_to_group':            'group',
      'membership_request_approved':    'group',
      'discussion_moved' :              'group',
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
      'user_mentioned':                 'comment',
      'invitation_accepted':            'membership',
      'new_coordinator':                'membership'
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
      switch @kind
        when 'discussion_moved', 'membership_request_approved', 'user_added_to_group' then @recordStore.groups.find(@groupId)
        when 'membership_requested' then @membershipRequest().group()
        when 'invitation_accepted', 'new_coordinator' then @membership().group()
        when 'new_discussion', 'discussion_edited' then @discussion().group()

    delete: ->
      @deleted = true

    actorName: ->
      @actor().name

    relevantRecordType: ->
      @constructor.eventTypeMap[@kind]

    relevantRecord: ->
      @[@relevantRecordType()]()
