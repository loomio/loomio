Records = require 'shared/services/records'

{ listenForLoading } = require 'shared/helpers/listen'

angular.module('loomioApp').factory 'InstallMicrosoftModal', ->
  templateUrl: 'generated/components/install_microsoft/modal/install_microsoft_modal.html'
  controller: ['$scope', 'group', ($scope, group) ->
    $scope.groupIdentity = Records.groupIdentities.build
      groupId: group.id
      identityType: 'microsoft'
      eventKinds:
        new_discussion: true
        poll_created: true
        poll_closing_soon: true
        poll_expired: true
        outcome_created: true

    listenForLoading $scope
  ]
