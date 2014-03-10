
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

  $('#genzero').on 'click', () ->
    $('#prototype-carousel').carousel(0)
  $('#pathways').on 'click', () ->
    $('#prototype-carousel').carousel(1)
  $('#timebank').on 'click', () ->
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

  $('#prototype-carousel').on 'slide.bs.carousel', (e) ->
    oldIndex = $(this).find('.active').index()
    newIndex = $(e.relatedTarget).index()

    fadeInGroup = (key) ->
      console.log key, 'in'
      element = '#' + key
      $(element).find('.group').addClass('active')
      $(element).addClass('active')
      return

    fadeOutGroup = (key) ->
      console.log key, 'out'
      element = '#' + key
      $(element).find('.group').removeClass('active')
      $(element).removeClass('active')
      return

    switch oldIndex
      when 0 then fadeOutGroup('genzero')
      when 1 then fadeOutGroup('pathways')
      when 2 then fadeOutGroup('timebank')
      when 3 then fadeOutGroup('nvc')

    switch newIndex
      when 0 then fadeInGroup('genzero')
      when 1 then fadeInGroup('pathways')
      when 2 then fadeInGroup('timebank')
      when 3 then fadeInGroup('nvc')

  return
