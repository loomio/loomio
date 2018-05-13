FlashService  = require 'shared/services/flash_service'
LmoUrlService = require 'shared/services/lmo_url_service'

angular.module('loomioApp').factory 'ConfirmModal', ->
  templateUrl: 'generated/components/confirm_modal/confirm_modal.html'
  controller: ['$scope', 'confirm', ($scope, confirm) ->
    $scope.confirm  = confirm
    $scope.fragment = "generated/components/fragments/#{confirm.text.fragment}.html" if confirm.text.fragment

    $scope.submit = (args...) ->
      $scope.isDisabled = true
      $scope.confirm.submit(args...).then ->
        $scope.$close()
        LmoUrlService.goTo $scope.confirm.redirect     if $scope.confirm.redirect?
        $scope.confirm.successCallback(args...)        if typeof $scope.confirm.successCallback is 'function'
        FlashService.success $scope.confirm.text.flash if $scope.confirm.text.flash
      .finally ->
        $scope.isDisabled = false

    _.merge $scope, confirm.scope
  ]
