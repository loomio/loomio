canvasSupported = !!window.HTMLCanvasElement
html5 = exports ? this
html5.supported = true if canvasSupported

$ ->
  # Only execute on group page
  if $("body.groups").length > 0
    $("#membership-requested").hover(
      (e) ->
        $(this).text("Cancel Request")
      (e) ->
        $(this).text("Membership Requested")
    )
  # Add a group description
  $ ->
    if $("body.groups").length > 0
      $("#add-description").click((event) ->
        $("#description-placeholder").toggle()
        $("#add-group-description").toggle()
        event.preventDefault()
      )
      $("#edit-description").click((event) ->
        $("#group-description").toggle()
        $("#add-group-description").toggle()
        event.preventDefault()
      )
      $("#cancel-add-description").click((event) ->
        $("#add-group-description").toggle()
        if $("#group-description").text().match(/\S/)
          $("#group-description").toggle()
        else
          $("#description-placeholder").toggle()
        event.preventDefault()
      )

#*** tick on proposal dropdown ***
$ ->
  $("#display-closed").click((event) ->
    $("#open").hide()
    $("#closed").show()
    $("#tick-closed").show()
    $("#tick-current").hide()
    $("#proposal-phase").text("Closed proposals")
    event.preventDefault()
  )
  $("#display-current").click((event) ->
    $("#open").show()
    $("#closed").hide()
    $("#tick-current").show()
    $("#tick-closed").hide()
    $("#proposal-phase").text("Current proposals")
    event.preventDefault()
  )

#*** add member form ***
$ ->
  # Only execute on group page
  if $("body.groups").length > 0
    $(".group-add-members").click((event) ->
      $(".group-add-members").hide()
      $("#invite-group-members").show()
      $("#user_email").focus()
      event.preventDefault()
    )
    $("#cancel-add-members").click((event) ->
      $(".group-add-members").show()
      $("#invite-group-members").hide()
      event.preventDefault()
    )

#*** ajax for discussions on group page ***

# closed proposals
$ ->
  if $("body.groups.show").length > 0
    idStr = new Array
    idStr = $('#group-closed-motions').children().attr('class').split('_')
    $('#group-closed-motions').load("/groups/#{idStr[1]}/motions", ->
      $("#group-closed-motions").removeClass('hidden')
      $("#closed-motions-loading").hide()
    )
$ ->
  if $("body.groups.show").length > 0
    $(document).on('click', '#group-closed-motions .pagination a', (e)->
      unless $(this).parent().hasClass("gap")
        $("#closed-motion-list").hide()
        $("#closed-motions-loading").show()
        $('#group-closed-motions').load($(this).attr('href'), ->
          $("#closed-motion-list").show()
          $("#closed-motions-loading").hide()
        )
        e.preventDefault()
    )
# discussions

getNextURL = (button_url) -> 
  console.log("0" + button_url)
  current = document.URL
  lastBackslash = current.lastIndexOf("/")
  
  #checks if main url has backslash in the way
  if lastBackslash == current.length-1
    current = current.substr(0, lastBackslash)
    
  #if current is already on a page number remove current page number
  if current.lastIndexOf("?") > -1
    newURL = current.split("?")[0]
    console.log("1" + newURL)

  if button_url.lastIndexOf("?") > -1
  	console.log("2" + button_url)
  	page_number = button_url.split("?")
  	newURL = current + "?" + page_number[1]
    
  console.log("3 changing:" + button_url + " to:" + newURL)
  newURL
  
getPageParam = () ->
  url = $(location).attr("href")
  if url.lastIndexOf("?") > -1
    page = "?" + url.split("?")[1]
    page
  else
    ""

$ ->
  if $("body.groups.show").length > 0
    idStr = new Array
    idStr = $('#group-discussions').children().attr('class').split('_')
    params = getPageParam()
    $('#group-discussions').load("/groups/#{idStr[1]}/discussions" + params, ->
      Application.convertUtcToRelativeTime()
      $("#group-discussions").removeClass('hidden')
      $("#discussions-loading").hide()
    )
$ ->
  if $("body.groups.show").length > 0
    $(document).on('click', '#group-discussions .pagination a', (e)->
      unless $(this).parent().hasClass("gap")
        if html5.supported
          window.history.pushState("stateObj", "title_ignored", getNextURL($(this).attr("href")))
          console.log("html5 supported")
        $("#discussion-list").hide()
        $("#discussions-loading").show()
        $('#group-discussions').load($(this).attr('href'), ->
          Application.convertUtcToRelativeTime()
          $("#discussion-list").show()
          $("#discussions-loading").hide()
        )
        e.preventDefault()
    )