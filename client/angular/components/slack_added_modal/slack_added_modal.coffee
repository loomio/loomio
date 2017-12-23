Records = require 'shared/services/records.coffee'

angular.module('loomioApp').factory 'SlackAddedModal', (ModalService) ->
  templateUrl: 'generated/components/slack_added_modal/slack_added_modal.html'
  controller: ($scope, group) ->
    $scope.group = group
    $scope.submit = ->
      ModalService.open 'PollCommonStartModal', poll: -> Records.polls.build()
