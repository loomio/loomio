angular.module('loomioApp').factory 'FlashService', (FlashModel) ->
  new class FlashService

    constructor: ->
      @currentFlash = new FlashModel

    success: (message) ->
      set(@currentFlash, message, 'success')

    failure: (message) ->
      set(@currentFlash, message, 'danger')

    info: (message) ->
      set(@currentFlash, message, 'info')

    clear: -> 
      set(@currentFlash, null, null)

    set = (flash, message, level) ->
      flash.message = message
      flash.level = level