angular.module('loomioApp').directive 'threadVolumeCard', ->
  scope: {thread: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_volume_card/thread_volume_card.html'
  replace: true
  controller: ($scope, ModalService, ChangeVolumeForm) ->

    $scope.openChangeVolumeForm = ->
      ModalService.open ChangeVolumeForm, model: -> $scope.thread

    return
