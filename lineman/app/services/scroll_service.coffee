angular.module('loomioApp').factory 'ScrollService', ($timeout, $document) ->
  new class ScrollService

  scrollTo: (target, offset = 50, speed = 100) ->
    $timeout ->
      elem = angular.element(target)
      if elem.length
        $document.scrollToElement(elem, offset, speed)
        angular.element().focus(elem)
