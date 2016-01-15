angular.module('loomioApp').factory 'PageTitleService', ->
  new class PageTitleService
    title: 'Loomio',
    count: 0,
    set: ({title, count}) ->
      @title = _.trunc(title, 300) if title?
      @count = count if count?
      @apply()

    apply: ->
      prefix = if @count > 0 then "(#{@count}) " else ""
      document.querySelector('title').text = "#{prefix}#{@title} | Loomio"
