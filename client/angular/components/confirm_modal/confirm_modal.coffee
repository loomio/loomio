FlashService  = require 'shared/services/flash_service.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'

angular.module('loomioApp').factory 'ConfirmModal', ->
  templateUrl: 'generated/components/confirm_modal/confirm_modal.html'
  controller: ['$scope', 'confirm', ($scope, confirm) ->
    $scope.confirm = confirm

    $scope.submit = ->
      $scope.isDisabled = true
      $scope.confirm.submit().then (data) ->
        $scope.$close()
        LmoUrlService.goTo $scope.confirm.redirect if $scope.confirm.redirect?
        $scope.confirm.successCallback(data)       if typeof $scope.confirm.successCallback is 'function'
        FlashService.success $scope.confirm.text.flash
      .finally ->
        $scope.isDisabled = false
  ]
