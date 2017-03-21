angular.module('loomioApp').directive 'pollCommonShareCommunityForm', (Records, AppConfig, FlashService, ModalService, AddCommunityModal) ->
  scope: {poll: '='}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/share/community_form/poll_common_share_community_form.html'
  controller: ($scope) ->
    Records.communities.fetch(params: {poll_id: $scope.poll.id, types: AppConfig.thirdPartyCommunities})

    $scope.addCommunity = ->
      ModalService.open AddCommunityModal, poll: -> $scope.poll

    $scope.remind = console.log

    $scope.revoke = (community) ->
      community.destroy()
               .then ->
                 community.revoked = true
                 FlashService.success "poll_common_share_form.community_revoked"
