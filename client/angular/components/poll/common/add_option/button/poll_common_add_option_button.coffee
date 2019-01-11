ModalService = require 'shared/services/modal_service'

angular.module('loomioApp').directive 'pollCommonAddOptionButton', ->
  scope: {poll: '='}
  template: require('./poll_common_add_option_button.haml')
  replace: false
  controller: ['$scope', ($scope) ->
    $scope.open = ->
      ModalService.open 'PollCommonAddOptionModal', poll: -> $scope.poll
  ]
