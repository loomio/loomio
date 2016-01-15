angular.module('loomioApp').factory 'PageTitleService', ->
  new class PageTitleService
    title: 'Loomio',
    count: 0,
    set: ({title, count}) ->
      @title = "#{_.trunc(title, 300)} | Loomio" if title?
      @count = count if count?
      @apply()

    apply: ->
      document.querySelector('title').text = "#{@prefixFor(@count)}#{@title}"

    prefixFor: (count) ->
      if count > 0 then "(#{count}) " else ""
