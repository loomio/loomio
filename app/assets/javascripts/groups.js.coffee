# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  # Only execute on group page
  if $("#group").length > 0
    addUserTag = (group_id, tag_name, user_name) =>
      $.ajax("/groups/#{group_id}/user/#{user_name}/add_user_tag/#{tag_name}")

    deleteUserTag = (group_id, tag_name, user_name) =>
      $.ajax("/groups/#{group_id}/user/#{user_name}/delete_user_tag/#{tag_name}")

    $("#membership-requested").hover(
      (e) ->
        $(this).text("Cancel Request")
      (e) ->
        $(this).text("Membership Requested")
    )

    # For each user in the list, display their current group tags
    $("#users-list").children().each (index, user_list_element) =>
      token_display_element = $("#user-tags-#{$(user_list_element).attr("id")}")
      if (token_display_element.length > 0)
        group_id = $("#group_id").val()
        available_group_tags = "/groups/#{group_id}/group_tags.json"

        token_input_object = token_display_element.tokenInput(
          available_group_tags
          crossDomain: false, preventDuplicates: true, theme: "facebook"
          onAdd: (item)-> addUserTag group_id, item.name, $(user_list_element).attr("id")
          onDelete: (item)-> deleteUserTag group_id, item.name, $(user_list_element).attr("id")
        )

        # Prepopulate token inputs with tags

        $($("#user-existing-tags-#{$(user_list_element).attr("id")}").val().split(",")).each (index, element) =>
          if (element != "")
            token_input_object.tokenInput("add", {id: element, name: element})

    if window.location.href.split("#")[1] == "users"
      $(".tabs a:last").click()

