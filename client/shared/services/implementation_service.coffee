AppConfig = require 'shared/services/app_config'

module.exports = new class ImplementationService
  requireMethod: (service, method, setter) ->
    service[method] = ->
      console.error "NotImplementedError: #{message(method, setter)}"

    service[setter] = (fn) ->
      service[method] = fn

  allowMethod: (service, method, setter) ->
    service[method] = ->
      console.log "Warning: #{message(method, setter)}" if AppConfig.environment == 'development'

    service[setter] = (fn) ->
      service[method] = fn

message = (method, setter) ->
  "No #{method} method is set. Please call '#{setter}(fn)' to set one."
