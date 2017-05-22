angular.module('loomioApp').directive 'pollCommonShareGroupForm', (LmoUrlService, FlashService) ->
  scope: {poll: '='}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/share/group_form/poll_common_share_group_form.html'
  controller: ($scope) ->
    
