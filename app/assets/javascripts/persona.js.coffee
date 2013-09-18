$(".persona-login-button").click (e) ->
  e.preventDefault()

  navigator.id.get (assertion) ->
    if (assertion)
      $.ajax
        url: '/users/sign_in',
        type: "POST",
        dataType: "json",
        cache: false,
        data:
          "assertion": assertion
        success: (data, status) ->
          window.location.href = '/'
