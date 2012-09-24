window.Application ||= {}

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
    if form.parents("#motion-form").length > 0
      time_now = new Date()
      selected_date = new Date($("#motion_close_date").val())
      if selected_date <= time_now
        $(".validate-motion-close-date").parent().addClass("error")
        $(".date-error-message").show()

# character count for statement on discussion:show page
pluralize_characters = (num) ->
  if(num == 1)
    return num + " character"
  else
    return num + " characters"

# display charcaters left
display_count = (num, object) ->
  if(num >= 0)
    $(".character-counter").text(pluralize_characters(num) + " left")
    object.parent().removeClass("error")
  else
    num = num * (-1)
    $(".character-counter").text(pluralize_characters(num) + " too long")
    object.parent().addClass("error")

# character count for 250 characters max
$ ->
  $(".limit-250").keyup(() ->
    $(".error-message").hide()
    chars = $(".limit-250").val().length
    left = 250 - chars
    display_count(left, $(".limit-250"))
  )

 #character count for 150 characters max
$ ->
  $(".limit-150").keyup(() ->
    $(".error-message").hide()
    chars = $(".limit-150").val().length
    left = 150 - chars
    display_count(left, $(".limit-150"))
  )

#*** check if discussion with motions list is empty ***
$ ->
  if $("body.groups.show").length > 0 ||  $("body.dashboard.show").length > 0
    if $("#discussions-with-motions").children().html() != ""
      $(".discussion-with-motion-divider").removeClass('hidden')

# Edit description
$ ->
  if $("body.groups.show").length > 0 || $("body.discussions.show").length > 0
    $("#edit-description").click((event) ->
      description_height = $(this).parent().find(".model-description").height()
      $("#show-description").toggle()
      $("#add-edit-description").toggle()
      if description_height > 90
        $('#description-input').height(description_height)
      event.preventDefault()
    )
    $("#cancel-add-description").click((event) ->
      $("#add-edit-description").toggle()
      $("#show-description").toggle()
      event.preventDefault()
    )

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

#*** open-close motions dropdown***
$ ->
  if $("body.groups.show").length > 0 || $("body.dashboard.show").length > 0
    if $("body.groups.show").length > 0
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
