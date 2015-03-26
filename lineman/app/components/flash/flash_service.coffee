angular.module('loomioApp').factory 'FlashService', ($timeout, FlashModel) ->
  new class FlashService

    constructor: ->
      @currentFlash = new FlashModel

    good: (translateKey, translateValues) =>
      @set translateKey, "success", translateValues

    # sorry, but I cannot jam with this
    success: (recordName, action, options = {}) =>
      @set "#{recordName}_record.#{action}", "success", options

    info:    (message, options = {}) =>
      @set(message, 'info', options)

    failure: (errors, options = {}) =>
      @set(errors, 'danger', options)

    clear: =>
      @currentFlash.message = null
      @currentFlash.level   = null
      @currentFlash.options = null

    set: (message, level, options = {}) =>
      @currentFlash.message = message
      @currentFlash.level   = level
      @currentFlash.options = options
      $timeout.cancel @pending if @pending?
      @pending = $timeout @clear, 2000
