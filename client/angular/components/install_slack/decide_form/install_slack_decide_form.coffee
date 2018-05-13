AppConfig = require 'shared/services/session'
Records   = require 'shared/services/records'

{ applyPollStartSequence } = require 'shared/helpers/apply'

angular.module('loomioApp').directive 'installSlackDecideForm', ->
  scope: {group: '='}
  templateUrl: 'generated/components/install_slack/decide_form/install_slack_decide_form.html'
  controller: ['$scope', ($scope) ->
    $scope.poll = Records.polls.build groupId: $scope.group.id
    applyPollStartSequence $scope,
      afterSaveComplete: (event) ->
        $scope.announcement = Records.announcements.buildFromModel(event)
  ]
