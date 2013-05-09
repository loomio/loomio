$ ->
  # on click of dismiss link, hide then post
  $('a.dismiss-announcement').on 'click', (e) ->
    $(this).parents('.announcement').hide()
    $.post $(this).data('hide-path')
