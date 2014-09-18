$ ->
  toggle_post_comment_btn = ->
    val = $('#fileupload').data('uploads-in-progress')
    val ||= 0
    if val < 1
      $("#post-new-comment").removeAttr('disabled')
    else
      $("#post-new-comment").attr('disabled', 'disabled')

  upload_started = ->
    val = $('#fileupload').data('uploads-in-progress')
    val ||= 0
    val += 1
    $('#fileupload').data('uploads-in-progress', val)
    toggle_post_comment_btn()

  upload_stopped = ->
    val = $('#fileupload').data('uploads-in-progress')
    val -= 1
    $('#fileupload').data('uploads-in-progress', val)
    toggle_post_comment_btn()

  iframe_upload_redirect_url = ->
    $('#fileupload').data('redirect-url')+"/?%s"

  $('.comment-toolbar').on 'click', '#add-attachment-icon', ->
    $('input:file').trigger('click')

  $('#attachment-container').on 'click', '.attachment-success .remove-attachment', ->
    id = $(this).parent().data('attachment-id')
    $('#attachment-container [data-attachment-id="'+id+'"]').remove()

  $('#fileupload').fileupload
    add: (e, data) ->
      types = /(\.|\/)(exe)$/i
      file = data.files[0]
      megabytes = file.size / 1024 / 1024
      if megabytes > 100
        alert("The file is too big. It must be less than 100 MB.")
      else if types.test(file.type) || types.test(file.name)
        alert("#{file.name} is an .exe file, which is not allowed")
      else
        upload_started()
        data.context = $(tmpl("template-upload-in-progress", file))
        $('#attachment-container').append(data.context)
        $('#fileupload').data('filesize', data.files[0].size)
        $('#fileupload').data('filename', data.files[0].name)
        data.form.find('#content-type').val(file.type)
        jqXHR = data.submit()

        data.context.on 'click', '.cancel-upload', (e) ->
          jqXHR.abort()
          data.context.remove()
          upload_stopped()

    progress: (e, data) ->
      if data.context
        progress = parseInt(data.loaded / data.total * 100, 10)
        data.context.find('.progress-bar').css('width', progress + '%')

    done: (e, data) ->
      file = data.files[0]
      domain = $('#fileupload').attr('action')
      path = $('#fileupload input[name=key]').val().replace('${filename}', file.name)
      file.location = domain + path
      to = $('#fileupload').data('post')
      content = {}
      content[$('#fileupload').data('as')] = file.location
      content['attachment[filesize]'] = file.size
      content['attachment[filename]'] = file.name

      $.post(to, content).done (response) ->
        file.id = response['attachment_id']
        comment_input_field = $(tmpl("template-upload--comment-input", file))
        $('#attachment-container').append(comment_input_field)

        attachment_uploaded_dom = $(tmpl("template-upload--attached", file))
        data.context.replaceWith(attachment_uploaded_dom)
        upload_stopped()

    fail: (e, data) ->
      if data['textStatus'] != 'abort'
        alert("#{data.files[0].name} failed to upload.")
