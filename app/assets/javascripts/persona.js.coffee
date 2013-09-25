$(".persona-login-button").click (e) ->
  e.preventDefault()

  navigator.id.get (assertion) ->
    if (assertion)
      $.ajax
        url: '/persona/verify',
        type: "POST",
        dataType: "json",
        cache: false,
        data:
          "assertion": assertion
        success: (data, status) ->
          console.log data
          window.location.href = '/'
