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
