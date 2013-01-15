#*** ajax for discussions ***

# discussions
$ ->
  # params = Application.getPageParam()
  params = ""
  load_discussions(params)

load_discussions = (params, callback) ->
  $('#user-discussions').load("/discussions" + params, ->
    Application.convertUtcToRelativeTime()
    $("#user-discussions").removeClass('hidden')
    $("#discussions-loading").addClass('hidden')
    if callback isnt undefined
      callback()
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

$ ->
  $("#discussions-search-filter-input").keyup ->
    clearTimeout searchInputTimer
    if $("#discussions-search-filter-input").val().length >= 3 
      #wait till 'finished typing' - don't hit the server on every keypress
      searchInputTimer = setTimeout(filter_search, inputInterval)
    else
      #remove filter - load all discussions and unhighlight
      load_discussions("", ->
        $(".discussion-title").unhighlight()
      )

filter_search = () ->
    term = $("#discussions-search-filter-input").val()
    params = "?search=" + encodeURIComponent(term)
    load_discussions(params, ->
      $(".discussion-title").highlight(term)
    )
    
