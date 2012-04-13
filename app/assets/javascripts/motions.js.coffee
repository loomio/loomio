# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

current_tags = ""
current_tag_filter = "active"
$ ->
  if $("#motion-form").length > 0
    #** Edit Moition **
    date = new Date($("#motion_close_date").val())
    date_string = "#{date.getDate()}-#{date.getMonth() + 1}-#{date.getFullYear()}"
    hours = date.getHours()
    datetime_format = new Date(date_string)
    $("#input_date").datepicker({"dateFormat": "dd-mm-yy"})
    $("#input_date").datepicker("setDate", date_string)
    $("#date_hour").val(hours)

    #** New Motion **
    if $("#new-motion").length > 0
      datetime = new Date()
      datetime.setDate(datetime.getDate() + 7)
      hours = datetime.getHours()
      $("#input_date").datepicker({"dateFormat": "dd-mm-yy"})
      $("#input_date").datepicker("setDate", datetime)
      $("#date_hour").val(hours)
      $("#motion_close_date").val(datetime)

  #** Reload hidden close_date field **
  $("#input_date").change((e) ->
    date = $(this).val()
    day = date.substring(0,2)
    month = (parseInt(date.substring(3,5)) - 1).toString()
    year = date.substring(6,10)
    hour = $("#date_hour").val()
    local_datetime = new Date(year, month, day, hour)
    $("#motion_close_date").val(local_datetime)
  )
  $("#date_hour").change((e) ->
    date = $("#input_date").val()
    day = date.substring(0,2)
    month = (parseInt(date.substring(3,5)) - 1).toString()
    year = date.substring(6,10)
    hour = $(this).val()
    local_datetime = new Date(year, month, day, hour)
    $("#motion_close_date").val(local_datetime)
  )

  #** expand motion row on dashboard and match colour for legend **
  $(".bordered").click((event, ui) ->
    expandableRow = $(this).children().last()
    expandableRow.toggle()
    if expandableRow.is(":visible")
      $(this).find(".toggle-button").html('-')
      graph_legend = $(this).find(".jqplot-table-legend")
      if $(this).hasClass('closed')
        graph_legend.addClass('closed')
        graph_legend.removeClass('voting')
      else
        graph_legend.addClass('voting')
        graph_legend.removeClass('closed')
    else
      $(this).find(".toggle-button").html('+')
  )

  #** prevent expansion of motion **
  $(".no-toggle").click((event) ->
    event.stopPropagation()
  )

  #** limit character count for statement**
  pluralize_characters = (num) ->
    if(num == 1)
      return num + " character"
    else
      return num + " characters"

  $("#limited").keyup(() ->
    chars = $("#limited").val().length
    left = 249 - chars
    if(left >= 0)
      $(".char_count").text(pluralize_characters(left) + " left")
      $(".clearfix").removeClass("error")
    else
      left = left * (-1)
      $(".char_count").text(pluralize_characters(left) + " too long")
      $(".clearfix").addClass("error")
  )

  $(".vote").click((event) ->
    if $(".clearfix").hasClass("error")
      $('#new_vote').preventDefault()
    else
      $('#new_vote').submit()
  )

  #** limit character count for statement**
  pluralize_characters = (num) ->
    if(num == 1)
      return num + " character"
    else
      return num + " characters"

  $("#limited").keyup(() ->
    chars = $("#limited").val().length
    left = 249 - chars
    if(left >= 0)
      $(".char_count").text(pluralize_characters(left) + " left")
      $(".clearfix").removeClass("error")
    else
      left = left * (-1)
      $(".char_count").text(pluralize_characters(left) + " too long")
      $(".clearfix").addClass("error")
  )

  $(".vote").click((event) ->
    if $(".clearfix").hasClass("error")
      $('#new_vote').preventDefault()
    else
      $('#new_vote').submit()
  )

  #** tagging stuff **
  if $("#motion").length > 0
    $(".group-tags button").not(".not-used").each (index, element) ->
      $(element).click (event, element)->
        #event.preventDefault()
        processTagSelection(this)

  processTagSelection = (current_element) ->
    current_tag = current_element.innerText

    if (current_tag == "everyone")
      current_tags = ""
    else if ( current_tags.indexOf(current_tag) == -1)
      current_tags += ".#{current_tag}"
    else
      current_tags = current_tags.replace(".#{current_tag}", "")

    showVotesBasedOnTag(current_tags)
    toggleTagClasses(current_element, current_tag, current_tags)
    refreshStatsGraph()

  showVotesBasedOnTag = (tag_names) ->
    if (tag_names == "")
      $("#votes-table tr").each (index, element) ->
        $(element).show()
    else
      $("#votes-table tr.everyone").each (index, element) ->
        $(element).hide()
      $(current_tags.split(".")).each (index, element) ->
        if (element != "")
          $("#votes-table .#{element}").fadeIn()

  toggleTagClasses = (current_element, current_tag, current_tags) ->
    if ( current_tag == "everyone" && current_element.className != current_tag_filter)
      $(".group-tags button").each (index, element) ->
        $(element).removeClass(current_tag_filter)
    else
      #set the everyone link to not active
      $(".group-tags #everyone").removeClass(current_tag_filter)
    $(current_element).toggleClass(current_tag_filter)
    if ( current_tags == "" && current_tag != "everyone" )
      $(".group-tags #everyone").addClass(current_tag_filter)

  refreshStatsGraph = ->
    yes_count = getVoteCount("yes")
    abstain_count = getVoteCount("abstain")
    no_count = getVoteCount("no")
    block_count = getVoteCount("block")

    filtered_stats_data = [["Yes (#{yes_count})", yes_count, "Yes"], ["Abstain (#{abstain_count})", abstain_count, "Abstain"], ["No (#{no_count})", no_count, "No"], ["Block (#{block_count})", block_count, "Block"]]

    $('#graph').empty()

    this.pie_graph_view = new Tautoko.Views.Utils.GraphView
      el: '#graph.pie'
      id_string: 'graph'
      legend: true
      data: filtered_stats_data
      type: 'pie'
      tooltip_selector: '#tooltip'

  getVoteCount = (vote_type) ->
    vote_count = 0
    if ($("#votes-table img[alt='#{vote_type} image']").is(":visible"))
      vote_count = $("#votes-table img[alt='#{vote_type} image']").length
    return vote_count

  # NOTE (Jon): We should implement a better method for scoping javascript to specific pages
  # http://stackoverflow.com/questions/6167805/using-rails-3-1-where-do-you-put-your-page-specific-javascript-code
  if $("#motion").length > 0
    $("#description").html(linkify_html($("#description").html()))
    $(".comment-body").each(-> $(this).html(linkify_html($(this).html())))

