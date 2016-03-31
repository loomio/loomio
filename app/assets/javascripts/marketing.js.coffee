//= require jquery2
//= require ahoy
//= require bootstrap

$ ->
  $('#product-carousel').carousel('pause')

  $('#threads').on 'click', ->
    $('#product-carousel').carousel(0)
  $('#weaving').on 'click', ->
    $('#product-carousel').carousel(1)
  $('#braid').on 'click', ->
    $('#product-carousel').carousel(2)

  $('.carousel-inner').on 'click', ->
    $('#product-carousel').carousel('next')
  return

$ ->
  fadeIn = (key) ->
    element = '#' + key
    $(element).find('.step-img').removeClass('hide-background').find('.top').addClass('active')
    $(element).find('h2').addClass('active')
    $(element).find('p').addClass('active')
    return

  fadeOut = (key) ->
    element = '#' + key
    $(element).find('h2').removeClass('active')
    $(element).find('p').removeClass('active')
    $(element).find('.top').removeClass('active')
    $(element).find('.step-img').addClass("hide-background")
    return

  $('#product-carousel').on 'slide.bs.carousel', (e) ->
    oldIndex = $(this).find('.active').index()
    newIndex = $(e.relatedTarget).index()

    switch oldIndex
      when 0 then fadeOut('threads')
      when 1 then fadeOut('weaving')
      when 2 then fadeOut('braid')

    switch newIndex
      when 0 then fadeIn('threads')
      when 1 then fadeIn('weaving')
      when 2 then fadeIn('braid')

  return

ahoy.trackView()
