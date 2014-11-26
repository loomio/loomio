angular.module('loomioApp').factory 'FlashModel', ->
  class FlashModel
    constructor: (data = {}) ->
      @message = data.message
      @level = data.level

    hasManyMessages: ->
      Array.isArray @message