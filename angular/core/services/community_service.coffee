angular.module('loomioApp').factory 'CommunityService', ->
  new class CommunityService

    idFields =
      facebook: 'facebook_group_id'
      slack:    'slack_channel_id'

    alreadyOnPoll: (poll, obj) ->
      _.find poll.communities(), (community) ->
        # obj could be a CommunityModel, or a record returned from an API (like a facebook group or slack channel)
        if _.get(obj, 'constructor.constructor.name') == 'CommunityModel'
          community.id == obj.id
        else
          community.customFields[idFields[community.communityType]] == obj.id
