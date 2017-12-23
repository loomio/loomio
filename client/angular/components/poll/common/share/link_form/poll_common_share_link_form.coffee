LmoUrlService = require 'shared/services/lmo_url_service.coffee'

angular.module('loomioApp').directive 'pollCommonShareLinkForm', (FlashService) ->
  scope: {poll: '='}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/share/link_form/poll_common_share_link_form.html'
  controller: ($scope) ->
    $scope.shareableLink = LmoUrlService.poll($scope.poll, {}, absolute: true)

    $scope.setAnyoneCanParticipate = ->
      $scope.settingAnyoneCanParticipate = true
      $scope.poll.save()
            .then -> FlashService.success "poll_common_share_form.anyone_can_participate_#{$scope.poll.anyoneCanParticipate}"
            .finally -> $scope.settingAnyoneCanParticipate = false

    $scope.copied = -> FlashService.success('common.copied')
