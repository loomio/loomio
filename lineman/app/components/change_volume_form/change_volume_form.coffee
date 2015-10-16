angular.module('loomioApp').factory 'ChangeVolumeForm', ->
  templateUrl: 'generated/components/change_volume_form/change_volume_form.html'
  controller: ($scope, model, FlashService) ->
    $scope.model = model.clone()

    if $scope.model.constructor.singular == 'discussion'
      $scope.translateRoot = 'thread_volume_form'
    else
      $scope.translateRoot = 'group_volume_form'

    $scope.volumeLevels = ["loud", "normal", "quiet", "mute"]

    $scope.submit = ->
      $scope.isDisabled = true
      $scope.model.changeVolume($scope.model.volume).then ->
        $scope.isDisabled = false
        $scope.$close()
        FlashService.success "#{$scope.translateRoot}.messages.#{$scope.model.volume}",
          name: $scope.model.title

    return
