angular.module('loomioApp').factory 'ScrollService', ($timeout, $document) ->
  new class ScrollService

  scrollTo: (target, speed = 100) ->
    $timeout ->
      elem = angular.element(target)
      if elem.length
        $document.scrollToElement(elem, speed)
        angular.element().focus(elem)
