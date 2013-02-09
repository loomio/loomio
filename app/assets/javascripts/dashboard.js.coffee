#*** ajax for discussions ***

# discussions
$ ->
  # params = Application.getPageParam()
  load_discussions()

load_discussions = () ->
  params = ""
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
      $(".discussion-title").unhighlight()

discussions_filter = () ->
    term = $("#discussions-search-filter-input").val()
    params = "?query=" + encodeURIComponent(term)
    if $("body.groups.show").length > 0 && $('#group-discussions').html() != null
      params += "&group_id=" + $('#group-discussions').attr('data-group') 
      $("#all-discussions-loading").addClass('hidden')
      $("#group-discussions").addClass('hidden')
      $('#discussions-loading').removeClass('hidden')
      $('#group-discussions').load("/discussions/search" + params, ->
        Application.convertUtcToRelativeTime()
        $("#group-discussions").removeClass('hidden')
        $("#discussions-loading").addClass('hidden')
        $(".discussion-title").highlight(term)
      )
    else
      $("#all-discussions-loading").addClass('hidden')
      $('#user-discussions').addClass('hidden')
      $('#discussions-loading').removeClass('hidden')
      $('#user-discussions').load("/discussions/search" + params, ->
        Application.convertUtcToRelativeTime()
        $("#user-discussions").removeClass('hidden')
        $("#discussions-loading").addClass('hidden')
        $(".discussion-title").highlight(term)
      )

