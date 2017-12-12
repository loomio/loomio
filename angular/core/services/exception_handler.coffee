angular.module('loomioApp').factory '$exceptionHandler', ($log, AppConfig) ->
  if !AppConfig.errbit.key?
    return ->

  client = new airbrakeJs.Client
    projectId:  AppConfig.errbit.key
    projectKey: AppConfig.errbit.key
    reporter:   'xhr'
    host:       AppConfig.errbit.url

  client.addFilter (notice) ->
    notice.context.environment = AppConfig.environment
    if notice.errors[0].type == ""
      null
    else
      notice

  (exception, cause) ->
    $log.error(exception)
    client.notify
      error: exception,
      params:
        version:         AppConfig.version
        current_user_id: AppConfig.currentUserId
        angular_cause: cause
