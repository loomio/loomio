angular.module('loomioApp').directive 'addCommunityForm', ($window, $location, AppConfig, Records, Session, CommunityService, FormService, ModalService, LoadingService, PollCommonShareModal) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/add_community_form/add_community_form.html'
  controller: ($scope) ->
    Records.communities.fetch(params: {types: AppConfig.thirdPartyCommunities})
    Records.communities.fetch(params: {poll_id: $scope.poll.id, types: AppConfig.thirdPartyCommunities})

    $scope.community = Records.communities.build(pollIds: $scope.poll.id)
    $scope.previousCommunities = ->
      _.filter Session.user().communities(), (community) ->
        !CommunityService.alreadyOnPoll($scope.poll, community)

    $scope.addCommunity = (type) ->
      if $scope.identity(type)
        $scope.community.identityId = $scope.identity(type).id
        $scope.community.communityType = type
      else
        $scope.fetchAccessToken(type)

    $scope.addExistingCommunity = (community) ->
      community.add($scope.poll).then $scope.backToShareModal

    $scope.fetchAccessToken = (type) ->
      delete $location.search().share
      $location.search('add_community', type)
      $window.location = "#{type}/oauth"

    $scope.cancel = ->
      $scope.community.communityType = null

    $scope.submit = FormService.submit $scope, $scope.community,
      flashSuccess: "add_community_form.community_created",
      flashOptions: {type: $scope.community.communityType}
      successCallback: -> $scope.backToShareModal()

    $scope.backToShareModal = ->
      ModalService.open PollCommonShareModal, poll: -> $scope.poll

    $scope.identity = (type) ->
      switch (type or $scope.community.communityType)
        when 'facebook' then Session.user().facebookIdentity()
        when 'slack'    then Session.user().slackIdentity()

    add_community = $location.search().add_community
    identity      = $scope.identity(add_community)
    if identity
      $scope.community.communityType = add_community
      $scope.community.identityId    = identity.id
