angular.module('loomioApp').factory 'AhoyService', ($rootScope) ->
  if ahoy?
    ahoy.trackAll();

    $rootScope.$on 'modalOpened', (evt, modal) ->
      # regex match gives group_welcome_modal from /generated/bla/group_welcome_modal/group_welcome_modal.haml
      modalName = modal.templateUrl.match(/(\w+)\.html$/)[1]
      ahoy.track('modalOpened', {name: modalName})

  new class AhoyService
    track: (name, options = {}) ->
      if ahoy?
        ahoy.track(name, options)
