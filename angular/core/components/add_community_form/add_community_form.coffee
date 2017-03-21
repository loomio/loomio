angular.module('loomioApp').directive 'addCommunityForm', ($window, $location, Records, Session, FormService, ModalService, LoadingService, PollCommonShareModal) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/add_community_form/add_community_form.html'
  controller: ($scope) ->

    $scope.community = Records.communities.build(pollIds: $scope.poll.id)

    $scope.addCommunity = (type) ->
      if $scope.identity(type)
        $scope.identityId = $scope.identity(type)
        $scope.community.communityType = type
      else
        $scope.fetchAccessToken(type)

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

    if $scope.identity($location.search().add_community)
      $scope.communityForm = $location.search().add_community
