angular.module('loomioApp').factory 'ScrollService', ($timeout) ->
  new class ScrollService

  scrollTo: (target, options = {}) ->
    $timeout ->
      elem      = document.querySelector(target)
      container = document.querySelector(options.container or '.lmo-main-content')
      if options.bottom
          options.offset = document.documentElement.clientHeight - (options.offset or 100)
      if elem && container
        angular.element(container).scrollToElement(elem, options.offset or 50, options.speed or 100).then ->
          angular.element(window).triggerHandler('checkInView')
        elem.focus()
