# homepage scroll effect
$ ->
  $(".scroll-nav").click((event)->
    target = this.hash
    offsetIE7 = 0;
    if ($.browser.msie  && parseInt($.browser.version, 10) == 7)
      offsetIE7 = -34;
    event.preventDefault()
    $.scrollTo(target, 1000, {offset: offsetIE7})
    location.hash = target
  )
