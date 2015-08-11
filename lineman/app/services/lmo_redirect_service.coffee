angular.module('loomioApp').factory 'LmoRedirectService', ($window, $router) ->
  new class LmoRedirectService

    redirect: ($event, url) ->
      if $event.ctrlKey or $event.metaKey
        $window.open url, '_blank'
      else
        $router.navigate url
