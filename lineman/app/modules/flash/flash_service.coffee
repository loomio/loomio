angular.module('loomioApp').factory 'FlashService', ($timeout, FlashModel) ->
  new class FlashService

    constructor: ->
      @currentFlash = new FlashModel

    success: (message) => @set(message, 'success')
    failure: (message) => @set(message, 'danger')
    info:    (message) => @set(message, 'info')

    clear: =>
      @currentFlash.message = null
      @currentFlash.level = null

    set: (message, level) =>
      @currentFlash.message = message
      @currentFlash.level = level
      $timeout.cancel @pending if @pending?
      @pending = $timeout @clear, 4000