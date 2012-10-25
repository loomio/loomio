settings = $("#email-notifications-settings")
settings.find(".btn").each  ->
  $(this).removeClass("active")
if (<%= @receive_emails %>)
	settings.find("#turn-emails-on").addClass("active")
else
  settings.find("#turn-emails-off").addClass("active")