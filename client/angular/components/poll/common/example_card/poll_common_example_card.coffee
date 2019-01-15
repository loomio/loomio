I18n = require 'shared/services/i18n'

angular.module('loomioApp').directive 'pollCommonExampleCard', ->
  scope: {poll: '='}
  template: require('./poll_common_example_card.haml')
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.type = ->
      I18n.t("poll_types.#{$scope.poll.pollType}").toLowerCase()
  ]
