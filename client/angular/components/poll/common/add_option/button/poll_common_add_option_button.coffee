ModalService = require 'shared/services/modal_service'

angular.module('loomioApp').directive 'pollCommonAddOptionButton', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/add_option/button/poll_common_add_option_button.html'
  replace: false
  controller: ['$scope', ($scope) ->
    $scope.open = ->
      ModalService.open 'PollCommonAddOptionModal', poll: -> $scope.poll
  ]
