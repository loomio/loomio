$ ->
  $('#fileupload').fileupload
    dataType: 'json',
    done: (e, data) ->
      $.each data.result.files, (index, file) ->
        $('<p/>').text(file.name).appendTo(document.body);

    fail: (e, data) ->
      alert("#{data.files[0].name} failed to upload.")

  $('#fileupload').fileupload({ forceIframeTransport: true })
  $('#fileupload').fileupload( 'option', 'redirect', $('#fileupload').data('redirect-url')+"/?%s")
