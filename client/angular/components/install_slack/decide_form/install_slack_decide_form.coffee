AppConfig = require 'shared/services/session'
Records   = require 'shared/services/records'

{ applyPollStartSequence } = require 'shared/helpers/apply'

angular.module('loomioApp').directive 'installSlackDecideForm', ->
  scope: {group: '='}
  template: require('./install_slack_decide_form.haml')
  controller: ['$scope', ($scope) ->
    $scope.poll = Records.polls.build groupId: $scope.group.id
    applyPollStartSequence $scope,
      afterSaveComplete: (event) ->
        $scope.announcement = Records.announcements.buildFromModel(event)
  ]
