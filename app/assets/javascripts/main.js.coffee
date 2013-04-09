window.Application ||= {}

#*** CHECK HTML5 SUPPORT ***
# canvasSupported = !!window.HTMLCanvasElement
# Application.html5 = exports ? this
# Application.html5.supported = true if canvasSupported

Application.convertUtcToRelativeTime = ->
  if $(".utc-time").length > 0
    today = new Date()
    month = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun",
               "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ]
    date_offset = new Date()
    offset = date_offset.getTimezoneOffset()/-60
    $(".utc-time").each((index, element)->
      date = $(element).html()
      localDate = Application.timestampToDateObject(date)
      hours = localDate.getHours()
      mins = localDate.getMinutes()
      mins = "0#{mins}" if mins.toString().length == 1
      localDay = new Date(localDate.getFullYear(), localDate.getMonth(), localDate.getDate())
      todayDay = new Date(today.getFullYear(), today.getMonth(), today.getDate())
      if localDay.getTime() == todayDay.getTime()
        if hours < 12
          hours = 12 if hours == 0
          date_string = "#{hours}:#{mins} AM"
        else
          hours = 24 if hours == 12
          date_string = "#{hours-12}:#{mins} PM"
      else
        date_string = "#{localDate.getDate()} #{month[localDate.getMonth()]}"
      $(element).html(String(date_string))
      $(element).removeClass('utc-time')
      $(element).addClass('relative-time')
    )

Application.timestampToDateObject = (timestamp)->
  date = new Date()
  offset = date.getTimezoneOffset()/-60
  date.setYear(timestamp.substring(0,4))
  date.setMonth((parseInt(timestamp.substring(5,7), 10) - 1).toString(), timestamp.substring(8,10))
  date.setHours((parseInt(timestamp.substring(11,13), 10) + offset).toString())
  date.setMinutes(timestamp.substring(14,16))
  return date

Application.getNextURL = (button_url) ->
  current = document.URL
  newURL = current
  lastBackslash = current.lastIndexOf("/")
  #checks if main url has backslash in the way
  if lastBackslash == current.length-1
    current = current.substr(0, lastBackslash)
  #if current is already on a page number remove current page number
  if current.lastIndexOf("?") > -1
    newURL = current.split("?")[0]
  if button_url.lastIndexOf("?") > -1
    page_number = button_url.split("?")
    newURL = newURL + "?" + page_number[1]
  newURL

Application.getPageParam = () ->
  url = $(location).attr("href")
  if url.lastIndexOf("?") > -1
    page = "?" + url.split("?")[1]
    page
  else
    ""

# confirm dialog box for class ".confirm-dialog"
$ ->
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

$ ->
  $(".dismiss-help-notice").click((event)->
    $.post($(this).attr("href"))
    $(this).parent(".help-notice").remove()
    event.preventDefault()
    event.stopPropagation()
  )

 #The following methods are used to provide client side validation for
 #- character count
 #- presence required
 #- date validation specific for motion-form

$ ->
  $(".validate-presence").change(() ->
    if $(this).val() != ""
        $(this).parent().removeClass("error")
        $(this).parent().find(".presence-error-message").hide()
  )
$ ->
  $(".validate-presence").keyup(() ->
    $(this).parent().removeClass("error")
    $(this).parent().find(".presence-error-message").hide()
  )

$ ->
  $(".presence-error-message").hide()
  $(".date-error-message").hide()

  $(".run-validations").click((event, ui) ->
    form = $(this).parents("form")
    form.find(".validate-presence").each((index, element) ->
      if $(element).is(":visible") && $(element).val() == ""
        parent = $(element).parent()
        parent.addClass("error")
        parent.find(".presence-error-message").show()
    )

    runCustomValidations(form)

    form.find(".control-group").each((index, group) ->
      if $(group).hasClass("error")
        event.preventDefault()
    )
  )

  runCustomValidations = (form)->
    motionCloseDateValidation(form)

  motionCloseDateValidation = (form)->
    if form.parents("#motion-form").length > 0 || $('#edit-close-date').length > 0
      time_now = new Date()
      selected_date = new Date($("#motion_close_date").val())
      if selected_date <= time_now
        $(".validate-motion-close-date").parent().addClass("error")
        $(".date-error-message").show()

# adds bootstrap popovers to group activity indicators
$ ->
  $(".group-activity").tooltip
    placement: "top"
    title: 'There have been new comments since you last visited this group.'

# character count for statement on discussion:show page
pluralize_characters = (num) ->
  if(num == 1)
    return num + " character"
  else
    return num + " characters"

# display charcaters left
display_count = (num, object) ->
  if(num >= 0)
    object.parent().find(".character-counter").text(pluralize_characters(num) + " left")
    object.parent().removeClass("error")
  else
    num = num * (-1)
    object.parent().find(".character-counter").text(pluralize_characters(num) + " too long")
    object.parent().addClass("error")

# character count for 250 characters max
$ ->
  $(".limit-250").keyup(() ->
    $(".error-message").hide()
    chars = $(this).val().length
    left = 250 - chars
    display_count(left, $(this))
  )

 #character count for 150 characters max
$ ->
  $(".limit-150").keyup(() ->
    $(".error-message").hide()
    chars = $(this).val().length
    left = 150 - chars
    display_count(left, $(this))
  )

#*** check if discussion with motions list is empty ***
$ ->
  if $("body.groups.show").length > 0 ||  $("body.dashboard.show").length > 0
    if $("#discussions-with-motions").children().html() != ""
      $(".discussion-with-motion-divider").removeClass('hidden')

#*** graph ***
displayGraph = (this_pie, graph_id, data)->
  @pie_graph_view = new Loomio.Views.Utils.GraphView
    el: this_pie
    id_string: graph_id
    legend: false
    data: data
    type: 'pie'
    tooltip_selector: '#tooltip'
    diameter: 25
    padding: 1
    gap: 1
    shadow: 0.75

#*** hide/show mini-graph popovers
$ ->
  if $("body.groups.show").length > 0 || $("body.dashboard.show").length > 0
    $(".motion-popover-link").click((event) ->
      $(this).find('.pie').tooltip('hide')
      if $(this).find(".popover").html() == null
        event.stopPropagation()
        currentPie = this
        $('.motion-popover-link').each(() ->
          unless this == currentPie
            $(this).popover('hide')
        )
        $(this).find('.button_to').submit()
        $(this).popover('toggle')
    )
$ ->
  if $("body.groups.show").length > 0 || $("body.dashboard.show").length > 0
    $(document).click((event) ->
      $('.motion-popover-link').popover('hide')
    )

#*** closed motions modal***
$ ->
  if $("body.groups.show").length > 0 || $("body.dashboard.show").length > 0
    if $("body.groups.show").length > 0 && $("#private-message").length == 0
      idStr = new Array
      idStr = $('#closed-motions-page').children().attr('class').split('_')
    $("#show-closed-motions").click((event) ->
      $("#closed-motions").modal('toggle')
      $("#closed-motions-page").removeClass('hidden')
      $("#closed-motions-loading").removeClass('hidden')
      $("#closed-motions-list").addClass('hidden')
      if $("body.groups.show").length > 0
        pathStr = "/groups/#{idStr[1]}/motions"
      else
        pathStr = "/motions"
      $('#closed-motions-page').load(pathStr, ->
        $("#closed-motions-list").removeClass('hidden')
        $("#closed-motions-loading").addClass('hidden')
        $("#closed-motions").find('.pie').each(->
          displayGraph($(this), $(this).attr('id'),  $.parseJSON($(this).attr('data-votes')))
        )
      )
      event.preventDefault()
    )
    $("#closed-motions .close").click((event) ->
      $("#closed-motions").modal('toggle')
      event.preventDefault()
    )

#pagination load on closed motions
$ ->
  if $("body.groups.show").length > 0 || $("body.dashboard.show").length > 0
    $(document).on('click', '#closed-motions-page .pagination a', (e)->
      unless $(this).parent().hasClass("gap")
        $("#closed-motions-list").addClass('hidden')
        $("#closed-motions-loading").removeClass('hidden')
        $('#closed-motions-page').load($(this).attr('href'), ->
          $("#closed-motion-list").removeClass('hidden')
          $("#closed-motions-loading").addClass('hidden')
          $("#closed-motions").find('.pie').each(->
            displayGraph($(this), $(this).attr('id'),  $.parseJSON($(this).attr('data-votes')))
            )
          )
        e.preventDefault()
      )

# homepage accordion
$ ->
  $(".collapse").collapse()
