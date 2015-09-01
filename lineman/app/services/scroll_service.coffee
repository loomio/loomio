angular.module('loomioApp').factory 'ScrollService', ($timeout, $document) ->
  new class ScrollService

  scrollTo: (target, offset = 50, speed = 100) ->
    $timeout ->
      elem = document.querySelector(target)
      if elem
        $document.scrollToElement(elem, offset, speed)
        elem.focus()
