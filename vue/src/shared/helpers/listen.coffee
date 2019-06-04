import Records  from '@/shared/services/records'
import Session  from '@/shared/services/session'
import EventBus from '@/shared/services/event_bus'

export listenForTranslations = ($scope) ->
  true
  # EventBus.listen $scope, 'translationComplete', (e, translatedFields) =>
  #   return if e.defaultPrevented
  #   e.preventDefault()
  #   $scope.translation = translatedFields

export listenForLoading = ($scope) ->
  EventBus.listen $scope, 'processing',     -> $scope.isDisabled = true
  EventBus.listen $scope, 'doneProcessing', -> $scope.isDisabled = false
