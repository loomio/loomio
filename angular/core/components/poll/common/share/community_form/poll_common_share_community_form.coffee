angular.module('loomioApp').directive 'pollCommonShareCommunityForm', (Records, AppConfig, CommunityService, FlashService, ModalService, AddCommunityModal) ->
  scope: {poll: '='}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/share/community_form/poll_common_share_community_form.html'
  controller: ($scope) ->
    Records.communities.fetch(params: {poll_id: $scope.poll.id, types: AppConfig.thirdPartyCommunities})

    $scope.addCommunity = (type) ->
      return unless community = CommunityService.buildCommunity($scope.poll, type)
      ModalService.open AddCommunityModal, community: -> community

    $scope.remind = (community) ->
      community.remind($scope.poll)

    $scope.noCommunities = ->
      !_.find $scope.poll.communities(), (community) -> !community.revoked

    $scope.revoke = (community) ->
      Records.pollCommunities.revoke($scope.poll, community).then ->
        FlashService.success "poll_common_share_form.community_revoked"
