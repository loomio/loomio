Records  = require 'shared/services/records.coffee'
EventBus = require 'shared/services/event_bus.coffee'

angular.module('loomioApp').factory 'InvitationModal', ->
  templateUrl: 'generated/components/invitation/modal/invitation_modal.html'
  controller: ['$scope', 'group', ($scope, group) ->
    EventBus.listen $scope, 'nextStep', $scope.$close

    $scope.invitationForm = Records.invitationForms.build
      groupId: (group or {}).id

    $scope.groupName = ->
      (Records.groups.find($scope.invitationForm.groupId) or {}).name
  ]
