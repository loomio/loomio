angular.module('loomioApp').factory 'ChangeVolumeForm', ->
  templateUrl: 'generated/components/change_volume_form/change_volume_form.html'
  controller: ($scope, model, FormService, Session, FlashService) ->
    $scope.model = model.clone()
    $scope.volumeLevels = ["loud", "normal", "quiet"]

    $scope.defaultVolume = ->
      switch $scope.model.constructor.singular
        when 'discussion' then $scope.model.volume()
        when 'membership' then $scope.model.volume
        when 'user'       then $scope.model.defaultMembershipVolume

    $scope.buh =
      volume: $scope.defaultVolume()

    $scope.translateKey = (key) ->
      "change_volume_form.#{key || $scope.model.constructor.singular}"

    $scope.flashTranslation = ->
      key =
        if $scope.applyToAll
          switch $scope.model.constructor.singular
            when 'discussion' then 'membership'
            when 'membership' then 'all_groups'
            when 'user'       then 'all_groups'
        else
          $scope.model.constructor.singular
      "#{$scope.translateKey(key)}.messages.#{$scope.buh.volume}"

    $scope.submit = FormService.submit $scope, $scope.model,
      submitFn: (model) ->
        model.saveVolume($scope.buh.volume, $scope.applyToAll, $scope.setDefault)
      flashSuccess: $scope.flashTranslation

    return
