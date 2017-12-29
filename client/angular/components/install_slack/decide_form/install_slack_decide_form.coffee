Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'

{ applyPollStartSequence } = require 'angular/helpers/apply.coffee'

angular.module('loomioApp').directive 'installSlackDecideForm', ->
  templateUrl: 'generated/components/install_slack/decide_form/install_slack_decide_form.html'
  controller: ['$scope', ($scope) ->
    $scope.poll = Records.polls.build groupId: Session.currentGroupId()
    applyPollStartSequence $scope
  ]
