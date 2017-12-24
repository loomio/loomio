module.exports = new class ImplementationService
  requireMethod: (service, method, setter) ->
    service[method] = ->
      console.error "NotImplementedError: No #{method} method is set. Please call '#{setter}(fn)' to set one."

    service[setter] = (fn) ->
      service[method] = fn
