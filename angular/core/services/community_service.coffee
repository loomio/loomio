angular.module('loomioApp').factory 'CommunityService', ->
  new class CommunityService

    idFields =
      facebook: 'facebook_group_id'
      slack:    'slack_channel_id'

    alreadyOnPoll: (poll, obj) ->
      _.find poll.communities(), (community) ->
        community.customFields[idFields[community.communityType]] == obj.id
