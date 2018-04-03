EventBus = require 'shared/services/event_bus.coffee'

{ submitOnEnter } = require 'shared/helpers/keyboard.coffee'
{ submitStance }  = require 'shared/helpers/form.coffee'
{ buttonStyle }   = require 'shared/helpers/style.coffee'

angular.module('loomioApp').directive 'pollCommonVoteForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/common/vote_form/poll_common_vote_form.html'
  controller: ['$scope', '$element', ($scope, $element) ->
    $scope.selectedOptionId = $scope.stance.pollOptionId()

    $scope.submit = submitStance $scope, $scope.stance,
      prepareFn: ->
        $scope.stance.stanceChoicesAttributes = [
          poll_option_id: $scope.selectedOptionId
        ]

    $scope.isSelected = (option) ->
      $scope.selectedOptionId == option.id

    $scope.mdColors = (option) ->
      buttonStyle($scope.selectedOptionId == option.id)

    $scope.select = (option) ->
      $scope.selectedOptionId = option.id
      setTimeout -> EventBus.broadcast $scope, 'focusTextarea'

    submitOnEnter $scope, element: $element
  ]
