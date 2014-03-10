
$ ->
  $('#product-carousel').carousel('pause')
  $('#threads').on 'click', () ->
    $('#product-carousel').carousel(0)
  $('#weaving').on 'click', () ->
    $('#product-carousel').carousel(1)
  $('#braid').on 'click', () ->
    $('#product-carousel').carousel(2)

  $('.carousel-inner').on 'click', ->
    $('#product-carousel').carousel('next')
  return




$ ->
  $('#prototype-carousel').carousel('pause')
  $('#wikimedia').on 'click', () ->
    $('#prototype-carousel').carousel(0)
  $('#pathways').on 'click', () ->
    $('#prototype-carousel').carousel(1)
  $('#genzero').on 'click', () ->
    $('#prototype-carousel').carousel(2)
  $('#nvc').on 'click', () ->
    $('#prototype-carousel').carousel(3)


$ ->

  fadeIn = (key) ->
    element = '#' + key
    $(element).find('.step-img').removeClass('hide-background').find('.top').fadeTo(400, 0)
    $(element).find('h2').addClass('active')
    $(element).find('p').addClass('active')
    return

  fadeOut = (key) ->
    element = '#' + key
    $(element).find('h2').removeClass('active')
    $(element).find('p').removeClass('active')
    $(element).find('.top').fadeTo(300, 1, ->
      $(element).find('.step-img').addClass('hide-background')
      return
    )
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

$ ->

  fadeIn = (key) ->
    element = '#' + key
    $(element).find('.group').fadeTo(0, 0)
    $(element).addClass('active')
    return

  fadeOut = (key) ->
    element = '#' + key
    $(element).removeClass('active')
    $(element).find('.group').fadeTo(0, 1)
    return

  $('#prototype-carousel').on 'slide.bs.carousel', (e) ->
    oldIndex = $(this).find('.active').index()
    newIndex = $(e.relatedTarget).index()

    console.log oldIndex, newIndex

    switch oldIndex
      when 0 then fadeOut('wikimedia')
      when 1 then fadeOut('pathways')
      when 2 then fadeOut('genzero')
      when 3 then fadeOut('nvc')

    switch newIndex
      when 0 then fadeIn('wikimedia')
      when 1 then fadeIn('pathways')
      when 2 then fadeIn('genzero')
      when 3 then fadeIn('nvc')



  return
