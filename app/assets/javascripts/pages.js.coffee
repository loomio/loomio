$ ->
  $("body").on "click", "#mailchimp-subscribe-button", (e) ->
    $('#mailchimp-subscribe-button').hide()
    $('.mailchimp-subscribe-form').show()
  # Placeholder shim
  $.placeholder.shim();
