AppConfig = require 'shared/services/session.coffee'
Records   = require 'shared/services/records.coffee'

{ applyPollStartSequence } = require 'shared/helpers/apply.coffee'

angular.module('loomioApp').directive 'installSlackDecideForm', ->
  scope: {group: '='}
  templateUrl: 'generated/components/install_slack/decide_form/install_slack_decide_form.html'
  controller: ['$scope', ($scope) ->
    $scope.poll = Records.polls.build groupId: $scope.group.id
    applyPollStartSequence $scope
  ]
