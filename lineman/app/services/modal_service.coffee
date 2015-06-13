angular.module('loomioApp').factory 'ModalService', ($modal, $rootScope) ->
  new class ModalService
    open: (modal, resolve = {}) ->
      $rootScope.$broadcast 'modalOpened'
      $modal.open
        templateUrl: modal.templateUrl
        controller:  modal.controller
        resolve:     resolve
