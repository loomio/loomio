angular.module('loomioApp').factory 'TransitionService', ($window, AppConfig) ->
  new class TransitionService

    transition: (type, opts = {}) ->
      return unless $window.plugins and
                    $window.plugins.nativepagetransitions and
                    typeof $window.plugins.nativepagetransitions[type] is 'function'
      opts.androiddelay = opts.androiddelay or 100
      $window.plugins.nativepagetransitions[type](opts)
