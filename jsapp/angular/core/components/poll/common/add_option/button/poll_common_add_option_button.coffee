angular.module('loomioApp').directive 'pollCommonAddOptionButton', (ModalService, PollCommonAddOptionModal) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/add_option/button/poll_common_add_option_button.html'
  replace: true
  controller: ($scope) ->
    $scope.open = ->
      ModalService.open PollCommonAddOptionModal, poll: -> $scope.poll
