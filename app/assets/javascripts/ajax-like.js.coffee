$ ->
  $(document).on('click', '.comment-time a', (e)->
    unless $(this).parent().hasClass("gap")
      #check if like or unlike
      $(this).load($(this).attr('href'))
      e.preventDefault()
  )
 
success = () -> console.log("success!")