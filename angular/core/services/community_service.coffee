angular.module('loomioApp').factory 'CommunityService', ($location, $window, Records, Session, FormService, ModalService, PollCommonShareModal) ->
  new class CommunityService

    buildCommunity: (poll, type) ->
      if identityId = identityIdFor(type)
        Records.communities.build
          pollId:        poll.id
          communityType: type
          identityId:    identityId
      else
        @fetchAccessToken(type)

    identityIdFor = (type) ->
      return unless identityFn = Session.user()["#{type}Identity"]
      (identityFn.call(Session.user()) or {}).id

    fetchAccessToken: (type) ->
      delete $location.search().share
      $location.search('add_community', type)
      $window.location = "#{type}/oauth"
      false

    alreadyOnPoll: (poll, obj) ->
      _.find poll.communities(), (community) ->
        return false if community.revoked
        # obj could be a CommunityModel, or a record returned from an API (like a facebook group or slack channel)
        if _.get(obj, 'constructor.constructor.name') == 'CommunityModel'
          community.id == obj.id
        else
          community.customFields[idFields[community.communityType]] == obj.id

    idFields =
      facebook: 'facebook_group_id'
      slack:    'slack_channel_id'

    submitCommunity: (scope, model, options = {}) ->
      FormService.submit scope, model, _.merge(
        flashSuccess: "add_community_form.community_created",
        flashOptions: {type: model.communityType}
        successCallback: => @back(model.poll())
      , options)

    back: (poll) ->
      delete $location.search().add_community
      $location.search('share', true)
      ModalService.open PollCommonShareModal, poll: -> poll
