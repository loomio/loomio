angular.module('loomioApp').factory 'KeyEventModalService', ($modal, KeyEventService) ->
  new class KeyEventModalService

    openKeyboardShortcutModal: =>
      $modal.open
        templateUrl: 'generated/components/key_events/key_events_modal.html',
        controllerAs: 'keyEventsModal'
        controller: ->
          @shortcuts = _.map KeyEventService.keyboardShortcuts, (shortcut) ->
            key: shortcut.key
            description: _.snakeCase(shortcut.event)

          return