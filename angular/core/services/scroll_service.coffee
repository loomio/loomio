angular.module('loomioApp').factory 'ScrollService', ($timeout) ->
  new class ScrollService

  scrollTo: (target, offset = 50, speed = 100) ->
    $timeout ->
      elem      = document.querySelector(target)
      container = document.querySelector('.lmo-main-content')
      if elem && container
        angular.element(container).scrollToElement(elem, offset, speed).then ->
          angular.element(window).triggerHandler('checkInView')
        elem.focus()
