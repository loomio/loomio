I18n = require 'shared/services/i18n'

angular.module('loomioApp').directive 'pollCommonExampleCard', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/example_card/poll_common_example_card.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.type = ->
      I18n.t("poll_types.#{$scope.poll.pollType}").toLowerCase()
  ]
