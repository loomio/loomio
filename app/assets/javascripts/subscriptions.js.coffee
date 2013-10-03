$ ->
  btn = $("#subscription-submit")
  text = btn.val()
  $("input[name='subscription_form[preset_amount]']").change ->
    if $("input[name='subscription_form[preset_amount]']:checked").val() == '0'
      $("#lovenote").show()
      btn.val("Submit")
      btn.attr("data-disable-with", "Submit")
    else
      $("#lovenote").hide()
      btn.val(text)
      btn.attr("data-disable-with", text)
