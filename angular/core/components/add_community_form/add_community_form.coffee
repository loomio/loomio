angular.module('loomioApp').directive 'addCommunityForm', (Records, CommunityService, LoadingService, Session, ModalService, PollCommonShareModal) ->
  scope: {community: '='}
  templateUrl: 'generated/components/add_community_form/add_community_form.html'
  controller: ($scope) ->
    $scope.vars = {}

    $scope.fetchAccessToken = ->
      CommunityService.fetchAccessToken $scope.community.communityType

    actionNames =
      facebook: 'admin_groups'
      slack:    'channels'

    customFieldNames =
      facebook: 'facebook_group_name'
      slack:    'slack_channel_name'

    customFieldName = ->
      customFieldNames[$scope.community.communityType]

    $scope.fetch = ->
      Records.identities.performCommand($scope.community.identityId, actionNames[$scope.community.communityType]).then (response) ->
        $scope.allGroups = response
      , (response) ->
        $scope.error = response.data.error
    LoadingService.applyLoadingFunction $scope, 'fetch'
    $scope.fetch()

    $scope.reauth = ->
      CommunityService.fetchAccessToken($scope.community.communityType)

    $scope.groups = ->
      _.filter $scope.allGroups, (group) ->
        !CommunityService.alreadyOnPoll($scope.community.poll(), group, $scope.community.communityType) and
        (_.isEmpty($scope.vars.fragment) or group.name.match(///#{$scope.vars.fragment}///i))

    $scope.submit = CommunityService.submitCommunity $scope, $scope.community,
      prepareFn: ->
        $scope.community.customFields[customFieldName()] = _.find($scope.allGroups, (group) ->
          $scope.community.identifier == group.id
        ).name

    $scope.back = ->
      ModalService.open PollCommonShareModal, poll: -> $scope.community.poll()

    $scope.placeholderKey = ->
      "add_community_form.#{$scope.community.communityType}.fragment_placeholder"
