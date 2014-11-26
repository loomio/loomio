angular.module('loomioApp').factory 'FlashModel', ->
  class FlashModel
    constructor: (data = {}) ->
      @message = data.message
      @level = data.level

    messageIsArray: ->
      Array.isArray @message