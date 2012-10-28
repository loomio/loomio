# set the current group in the new discussion modal
$ ->
  if $("body.dashboard.show").length > 0
    $('.new-discussion-link').click((e) ->
      $('#new-discussion').find('#group_id').val($(this).children().first().data('group'))
    )