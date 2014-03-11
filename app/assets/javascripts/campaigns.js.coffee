$ ->
  $('.main-container.container, .toolbar-navigation, .navbar.navbar-fixed-top').addClass('js-campaign')
  $('#js-banner').show()

  $('#js-dismiss').click ->
    $('#js-banner').hide()
    $('.navbar-fixed-top').removeClass('js-campaign')
    $('.toolbar-navigation').removeClass('js-campaign')
    $('.main-container.container').css('padding-top', '40px')
