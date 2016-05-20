angular.module('loomioApp').factory 'TransitionService', ($window, $timeout, AppConfig) ->
  new class TransitionService

    beginTransition: (type, opts) ->
      return unless $window.plugins and
                    $window.plugins.nativepagetransitions and
                    typeof $window.plugins.nativepagetransitions[type] is 'function'
      $timeout -> $window.plugins.nativepagetransitions[type](opts)

    completeTransition: ->
      return unless $window.plugins and
                    $window.plugins.nativepagetransitions
      $window.plugins.nativepagetransitions.executePendingTransition()
