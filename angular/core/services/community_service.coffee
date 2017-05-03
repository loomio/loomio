angular.module('loomioApp').factory 'CommunityService', ($location, $window, Records, Session, FormService, ModalService, PollCommonPublishModal, PollCommonShareModal) ->
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

    alreadyOnPoll: (poll, obj, communityType) ->
      _.find poll.communities(), (community) ->
        !community.revoked and
        community.communityType == communityType and
        community.identifier == obj.id

    submitCommunity: (scope, model, options = {}) ->
      FormService.submit scope, model, _.merge(
        flashSuccess: "add_community_form.community_created",
        flashOptions: {type: model.communityType}
        successCallback: (response) ->
          delete $location.search().add_community
          $location.search('share', true)
          ModalService.open PollCommonPublishModal,
            poll:      -> model.poll()
            community: -> Records.communities.find(response.communities[0].id)
            back:      -> (-> ModalService.open PollCommonShareModal, poll: -> model.poll())
      , options)
