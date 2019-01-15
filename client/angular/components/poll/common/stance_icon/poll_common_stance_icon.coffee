{ fieldFromTemplate } = require 'shared/helpers/poll'

angular.module('loomioApp').directive 'pollCommonStanceIcon', ->
  scope: {stanceChoice: '='}
  template: require('./poll_common_stance_icon.haml')
  controller: ['$scope', ($scope) ->
    $scope.useOptionIcon = ->
      fieldFromTemplate($scope.stanceChoice.poll().pollType, 'has_option_icons')
  ]
