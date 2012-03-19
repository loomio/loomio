# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# TODO Check if group page - check the body class/id

current_user_tags = ""

$ ->
  # Only execute on group page
  if $("#group").length > 0
    group_id = $("#group_id").val()
    $("#users-list").children().each (index, element) =>
      $.ajax(
        url: '/users/' + $(element).attr("id")  + '/user_group_tags.json',
        success: (data, status, o) ->
          current_user_tags = eval(data)
          $("#user-tags-" + $(element).attr("id")).tokenInput(
            "/group/" + group_id + "/group_tags.json"
            prePopulate: current_user_tags, crossDomain: false, processPrePopulate: true, preventDuplicates: true, theme: "facebook",
            onAdd: (item)-> $.ajax("/groups/" + group_id + "/add_user_tag/" + item.name + "/user/" + $(element).attr("id")),
            onDelete: (item)-> $.ajax("/groups/" + group_id + "/delete_user_tag/" + item.name + "/user/" + $(element).attr("id")),
          )
        dataType: "text"
        type: "GET"
      )

    if window.location.href.split("#")[1] == "users"
      $(".tabs a:last").click()

