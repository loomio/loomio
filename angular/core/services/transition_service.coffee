angular.module('loomioApp').factory 'TransitionService', ($window, AppConfig) ->
  new class TransitionService

    beginTransition: (type, opts = {}) ->
      return unless $window.plugins and
                    $window.plugins.nativepagetransitions and
                    typeof $window.plugins.nativepagetransitions[type] is 'function'
      opts.androiddelay = opts.androiddelay or -1
      $window.plugins.nativepagetransitions[type](opts)

    completeTransition: ->
      return unless $window.plugins and
                    $window.plugins.nativepagetransitions and
                    $window.plugins.nativepagetransitions.executePendingTransition()
