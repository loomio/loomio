{ fieldFromTemplate } = require 'shared/helpers/poll'

angular.module('loomioApp').directive 'pollCommonStanceIcon', ->
  scope: {stanceChoice: '='}
  templateUrl: 'generated/components/poll/common/stance_icon/poll_common_stance_icon.html'
  controller: ['$scope', ($scope) ->
    $scope.useOptionIcon = ->
      fieldFromTemplate($scope.stanceChoice.poll().pollType, 'has_option_icons')
  ]
