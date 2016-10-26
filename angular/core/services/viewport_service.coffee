angular.module('loomioApp').factory 'ViewportService', ($window) ->
  new class ViewportService

    viewportSize: ->
      if $window.innerWidth < 480
        'small'
      else if $window.innerWidth < 992
        'medium'
      else
        'large'
