angular.module('loomioApp').factory 'InvitationModal', ->
  templateUrl: 'generated/components/invitation/modal/invitation_modal.html'
  controller: ($scope, group, LoadingService) ->
    $scope.group = group.clone()
    LoadingService.listenForLoading($scope)
    $scope.$on 'inviteComplete', $scope.$close
