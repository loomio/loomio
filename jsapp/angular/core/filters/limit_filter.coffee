angular.module('loomioApp').filter 'limitByFn', ->
  (items, f, args) ->
    items.slice 0, f(args) if items
