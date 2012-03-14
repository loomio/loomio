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

    # Call this method to display user tags using the jQuery TokenInput Plugin
    displayUserTag = (group_id, element, token_diplay_element) =>
      current_user_group_tags_url = "/groups/#{group_id}/user/#{$(element).attr('id')}/user_group_tags.json"
      available_group_tags = "/groups/#{group_id}/group_tags.json"
    
      $.ajax(
        url: current_user_group_tags_url, 
        success: (data, status, o) ->
          current_user_tags = eval(data)
          $(token_diplay_element).tokenInput(
            available_group_tags
            prePopulate: current_user_tags, crossDomain: false, processPrePopulate: true, preventDuplicates: true, theme: "facebook"
            onAdd: (item)-> addUserTag group_id, item.name, $(element).attr("id")
            onDelete: (item)-> deleteUserTag group_id, item.name, $(element).attr("id")
          )
        dataType: "text"
        type: "GET"
      )

    $("#membership-requested").hover(
      (e) ->
        $(this).text("Cancel Request")
      (e) ->
        $(this).text("Membership Requested")
    )

    # For each user in the list, display their current group tags
    $("#users-list").children().each (index, user_list_element) => 
      token_diplay_element = "#user-tags-#{$(user_list_element).attr("id")}"
      displayUserTag $("#group_id").val(), user_list_element, token_diplay_element
    
    if window.location.href.split("#")[1] == "users"
      $(".tabs a:last").click()

