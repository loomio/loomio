#*** ajax for discussions ***

# discussions
$ ->
  load_discussions()

load_discussions = () ->
  params = ""
  if $("body.groups.show").length > 0 && $('#group-discussions').html() != null
    idStr = $('#group-discussions').attr('data-group')
    $('#group-discussions').load("/groups/#{idStr}/discussions" + params, ->
      Application.convertUtcToRelativeTime()
      $("#group-discussions").removeClass('hidden')
      $("#discussions-loading").addClass('hidden')
      activate_discussions_tooltips()
    )
  else
    $('#user-discussions').load("/discussions" + params, ->
      Application.convertUtcToRelativeTime()
      $("#user-discussions").removeClass('hidden')
      $("#discussions-loading").addClass('hidden')
    )
  $("#all-discussions-loading").addClass('hidden')  

$ ->
  $(document).on('click', '#user-discussions .pagination a', (e)->
    unless $(this).parent().hasClass("gap")
      # if Application.html5.supported
      #   window.history.pushState("stateObj", "title_ignored", Application.getNextURL($(this).attr("href")))
      $("#discussion-list").addClass('hidden')
      $("#discussions-with-motions").hide()
      $("#discussions-loading").removeClass('hidden')
      $('#user-discussions').load($(this).attr('href'), ->
        Application.convertUtcToRelativeTime()
        if document.URL.indexOf("page") == -1
          $("#discussions-with-motions").show()
        $("#discussion-list").removeClass('hidden')
        $("#discussions-loading").addClass('hidden')
        term = $("#discussions-search-filter-input").val()
        if term.length >= 3
          $(".discussion-title .title").highlight(term)  
      )
      e.preventDefault()
  )

$ ->
  if $("body.groups.show").length > 0
    $(document).on('click', '#group-discussions .pagination a', (e)->
      unless $(this).parent().hasClass("gap")
        # if Application.html5.supported
        #   window.history.pushState("stateObj", "title_ignored", Application.getNextURL($(this).attr("href")))
        $("#discussion-list").addClass('hidden')
        $("#discussions-loading").removeClass('hidden')
        $('#group-discussions').load($(this).attr('href'), ->
          Application.convertUtcToRelativeTime()
          $("#discussion-list").removeClass('hidden')
          $("#discussions-loading").addClass('hidden')
          term = $("#discussions-search-filter-input").val()
          if term.length >= 3
            $(".discussion-title .title").highlight(term)   
          activate_discussions_tooltips()
        )
        e.preventDefault()
    )

searchInputTimer = undefined
inputInterval = 500

# ajax for discussions filter/search input
$ ->
  $("#discussions-search-filter-input").keyup ->
    clearTimeout searchInputTimer
    if $("#discussions-search-filter-input").val().length >= 3 
      #wait till 'finished typing' - don't hit the server on every keypress
      searchInputTimer = setTimeout(discussions_filter, inputInterval)
    else
      #remove filter - load all discussions and unhighlight
      load_discussions()
      $("#discussions-with-motions").removeClass('hidden')
      $(".discussion-title .title").unhighlight()

discussions_filter = () ->
    term = $("#discussions-search-filter-input").val()
    params = "?query=" + encodeURIComponent(term)
    if $("body.groups.show").length > 0 && $('#group-discussions').html() != null
      params += "&group_id=" + $('#group-discussions').attr('data-group') 
      $("#all-discussions-loading").addClass('hidden')
      $("#group-discussions").addClass('hidden')
      $("#discussions-with-motions").addClass('hidden')
      $('#discussions-loading').removeClass('hidden')
      $('#group-discussions').load("/discussions/search" + params, ->
        Application.convertUtcToRelativeTime()
        $("#group-discussions").removeClass('hidden')
        $("#discussions-loading").addClass('hidden')
        $(".discussion-title .title").highlight(term)
      )
    else
      $("#all-discussions-loading").addClass('hidden')
      $('#user-discussions').addClass('hidden')
      $("#discussions-with-motions").addClass('hidden')
      $('#discussions-loading').removeClass('hidden')
      $('#user-discussions').load("/discussions/search" + params, ->
        Application.convertUtcToRelativeTime()
        $("#user-discussions").removeClass('hidden')
        $("#discussions-loading").addClass('hidden')
        $(".discussion-title .title").highlight(term)
      )

$ ->
  if $("body.groups.show").length > 0
    $("#membership-requested").hover(
      (e) ->
        $(this).text("Cancel Request")
      (e) ->
        $(this).text("Membership Requested")
    )

#*** edit privacy settings from dropdown ***
$ ->
  if $("#privacy-settings-form").length > 0
    $(".privacy-item").click((event) ->
        $('#viewable_by').val($(this).children().attr('class'))
        $(".privacy-item").find('.icon-ok').removeClass('icon-ok')
        $(this).children().first().children().addClass('icon-ok')
        $("#privacy-settings-form").submit()
        event.preventDefault()
    )

activate_discussions_tooltips = () ->
  $(".unread-group-activity").tooltip
    placement: "top"
    title: 'There have been new comments on this discussion since you last visited the group.'

$ ->
  $("#privacy").tooltip
    placement: "right"
