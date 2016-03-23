angular.module('loomioApp').factory 'AhoyService', ($rootScope, $location, $timeout) ->
  if ahoy?

    ahoy.trackClicks();
    ahoy.trackSubmits();
    ahoy.trackChanges();

    # ahoy.trackViews does not work in angular, so we fake it
    $rootScope.$watch ->
      $location.path()
    , (path) ->
      properties =
        url: $location.absUrl()
        title: document.title
        page: $location.path()

      ahoy.track properties

    $rootScope.$on 'modalOpened', (evt, modal) ->
      # regex match gives group_welcome_modal from /generated/bla/group_welcome_modal/group_welcome_modal.haml
      modalName = modal.templateUrl.match(/(\w+)\.html$/)[1]
      ahoy.track('modalOpened', {name: modalName})

  new class AhoyService
    track: (name, options = {}) ->
      if ahoy?
        ahoy.track(name, options)
