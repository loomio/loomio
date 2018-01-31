Records  = require 'shared/services/records.coffee'
Session  = require 'shared/services/session.coffee'
EventBus = require 'shared/services/event_bus.coffee'

angular.module('loomioApp').directive 'linkExplanationForm', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/link_explanation_form/link_explanation_form.html'
  controller: ['$scope', ($scope) ->
    if $scope.poll.anyoneCanParticipate && !Session.user().hasExperienced('shareableLink')
      Records.users.saveExperience 'shareableLink'
    else
      EventBus.emit $scope, 'nextStep'
  ]
