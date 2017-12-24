FlashService = require 'shared/services/flash_service.coffee'

angular.module('loomioApp').factory 'ConfirmModal', ->
  templateUrl: 'generated/components/confirm_modal/confirm_modal.html'
  controller: ($scope, submit, text, forceSubmit) ->
    $scope.submit      = submit
    $scope.forceSubmit = forceSubmit
    $scope.text        = _.merge(submit: "common.action.ok", text)

    $scope.submit = ->
      $scope.isDisabled = true
      submit().then(->
        $scope.$close()
        FlashService.success $scope.text.flash
      ).finally ->
        $scope.isDisabled = false
