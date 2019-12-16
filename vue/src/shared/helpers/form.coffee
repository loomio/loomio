export onError = (model, cb) ->
  (response) ->
    cb(response) if typeof cb is 'function'
    setErrors(model, response) if _.includes([401, 422], response.status)

setErrors = (model, response) ->
  response.json().then (r) ->
    model.setErrors(r.errors)

errorTypes =
  400: 'badRequest'
  401: 'unauthorizedRequest'
  403: 'forbiddenRequest'
  404: 'resourceNotFound'
  422: 'unprocessableEntity'
  500: 'internalServerError'
