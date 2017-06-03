angular.module('loomioApp').factory 'InvitationForm', ->
  templateUrl: 'generated/components/invitation/modal/invitation_modal.html'
  controller: ($scope, group) ->
    $scope.group = group.clone()
