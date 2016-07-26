angular.module('loomioApp').factory 'AhoyService', ($rootScope, $window) ->
  new class AhoyService
    init: ->
      return unless ahoy?

      ahoy.trackClicks()
      ahoy.trackSubmits()
      ahoy.trackChanges()

      # track page views
      $rootScope.$on 'currentComponent', =>
        @track '$view',
          page:  $window.location.pathname
          url:   $window.location.href
          title: document.title

      # track modal views
      $rootScope.$on 'modalOpened', (_, modal) =>
        # regex match gives group_welcome_modal from /generated/bla/group_welcome_modal/group_welcome_modal.haml
        @track 'modalOpened', name: modal.templateUrl.match(/(\w+)\.html$/)[1]

    track: (event, options) ->
      ahoy.track(event, options) if ahoy?
