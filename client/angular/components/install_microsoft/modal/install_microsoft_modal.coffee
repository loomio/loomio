Records = require 'shared/services/records'

{ listenForLoading } = require 'shared/helpers/listen'

angular.module('loomioApp').factory 'InstallMicrosoftModal', ->
  templateUrl: 'generated/components/install_microsoft/modal/install_microsoft_modal.html'
  controller: ['$scope', 'group', ($scope, group) ->
    $scope.groupIdentity = Records.groupIdentities.build
      groupId: group.id
      identityType: 'microsoft'

    listenForLoading $scope
  ]
