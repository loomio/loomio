angular.module('loomioApp').directive 'threadVolumeCard', ->
  scope: {thread: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_volume_card/thread_volume_card.html'
  replace: true
  controller: ($scope, ModalService, CurrentUser, ChangeThreadVolumeForm) ->

    $scope.openChangeVolumeForm = ->
      ModalService.open ChangeThreadVolumeForm, thread: -> $scope.thread

    $scope.canChangeVolume = ->
      CurrentUser.isMemberOf($scope.thread.group())

    return
