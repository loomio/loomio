$ ->
  current_locale = $('html').attr('locale')
  $.ajax
    url: "/detect_locale?current_locale=#{current_locale}"
    success: (data) ->
      $('body').prepend(data)
    dataType: 'html'
