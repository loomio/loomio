window.Application ||= {}

# keyboard shortcuts
$ ->
  $(document).on 'keydown', (event) ->
    if document.activeElement.tagName not in ['INPUT', 'TEXTAREA', 'SELECT']
      switch event.which
        when 71 # G for groups search dropdown
          $('#groups>a').click()
          $('#groups').find('.group-dropdown-search').focus()
          event.preventDefault()
        when 78 # N for notifications dropdown
          $('#notifications-container>a').click()
        when 83 # S for search box
          $('#search_form_query').focus()
          event.preventDefault()
        when 85 # U for user dropdown
          $("#user>a").click()

  $(".dismiss-help-notice").click (event)->
    $.post($(this).attr("href"))
    $('.help-notice').modal('hide')
    event.preventDefault()
    event.stopPropagation()

$ -> # check if discussion with motions list is empty
  if $("body.groups.show").length > 0 ||  $("body.dashboard.show").length > 0
    if $("#discussions-with-motions").children().html() != ""
      $(".discussion-with-motion-divider").removeClass('hidden')

$ -> # Confirm dialog box for class ".confirm-dialog"
  $("body").on("click", ".confirm-dialog", (event)->
    this_link = $(event.currentTarget)
    titleText = this_link.data("title")
    bodyText = this_link.data("body")
    methodText = this_link.data("method-type")
    if methodText == 'delete'
      buttonType = 'btn-danger'
    else
      buttonType = 'btn-info'
    confirmPath = this_link.data("confirm-path")
    csrf = $('meta[name=csrf-token]').attr("content")
    $('body').append("<div class='modal' id='confirm-dialog-modal'><div class='modal-header'>
      <a data-dismiss='modal' class='close'>×</a><h3>Confirm action</h3></div>
      <form action=#{confirmPath} method='post'>
      <div style='margin:0;padding:0;display:inline'><input name='utf8' type='hidden' value='✓'>
      <input name='_method' type='hidden' value='#{methodText}'>
      <input name='authenticity_token' type='hidden' value=#{csrf}></div>
      <div class='modal-body center'> #{bodyText}</div><div class='modal-footer'>&nbsp;
      <input class= 'btn #{buttonType}', name='commit' type='submit' value='#{titleText}' id='confirm-action'
             data-disable-with='#{titleText}'>
      <a data-dismiss='modal' class='btn'>Cancel</a></div></div></form>"
    )
    $('#confirm-dialog-modal').modal('show')
    $('#confirm-dialog-modal').on('hidden', ->
      $(this).remove()
    event.preventDefault()
    )
  )

# Placeholder shim
$.placeholder.shim();

# throws a warning if you try to navigate away from a page with unsaved form changes
# todo: translate the warning message
$ ->
  $('.js-warn-before-navigating-away').safetynet()
