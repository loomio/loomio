angular.module('loomioApp').factory 'PollCommonEmbedModal', ($translate, AppConfig, FlashService) ->
  templateUrl: 'generated/components/poll/common/embed_modal/poll_common_embed_modal.html'
  controller: ($scope, poll) ->
    $scope.poll         = poll
    $scope.baseUrl      = AppConfig.baseUrl
    $scope.minifiedCode = $translate.instant('poll_common_embed_modal.minified_code', host: $scope.baseUrl, key: $scope.poll.key)
    $scope.copied       = -> FlashService.success('common.copied')
