angular.module('loomioApp').factory 'EventModel', (BaseModel) ->
  class EventModel extends BaseModel
    @singular: 'event'
    @plural: 'events'
    @indices: ['id', 'discussionId']

    @eventTypeMap: {
      'user_added_to_group':            'group',
      'membership_request_approved':    'group',
      'membership_requested':           'group',
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

    delete: ->
      @deleted = true

    membership: ->
      @recordStore.memberships.find(@membershipId)

    membershipRequest: ->
      @recordStore.membershipRequests.find(@membershipRequestId)

    group: ->
      @recordStore.groups.find(@groupId)

    discussion: ->
      @recordStore.discussions.find(@discussionId)

    comment: ->
      @recordStore.comments.find(@commentId)

    proposal: ->
      @recordStore.proposals.find(@proposalId)

    vote: ->
      @recordStore.votes.find(@voteId)

    actor: ->
      @recordStore.users.find(@actorId)

    actorName: ->
      @actor().name

    relevantRecordType: ->
      @constructor.eventTypeMap[@kind]

    recordEdit: ->
      @recordStore.recordEdits.find(@recordEditId)
