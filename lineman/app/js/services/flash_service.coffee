angular.module('loomioApp').factory 'FlashService', (FlashModel) ->
  new class FlashService

    constructor: ->
      @currentFlash = new FlashModel

    setFlash: (message, level) ->
      @currentFlash.message = message
      @currentFlash.level = level

    clear: -> 
      @currentFlash.level = null
      @currentFlash.message = null
