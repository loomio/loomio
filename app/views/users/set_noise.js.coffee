settings = $("#noise-level-setting-group-<%= @group.id %>")
settings.find(".btn").each  ->
  $(this).removeClass("active")
settings.find(".set-noise-level-<%= @noise_level %>").addClass("active")