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

    form.find(".control-group").each((index, group) ->
      if $(group).hasClass("error")
        event.preventDefault()
    )
  )

