angular.module('loomioApp').factory 'InvitationModal', ->
  templateUrl: 'generated/components/invitation/modal/invitation_modal.html'
  controller: ($scope, group) ->
    $scope.group = group.clone()

    $scope.$on 'inviteComplete', $scope.$close
