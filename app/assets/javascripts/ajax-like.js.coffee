like = true
unlike = false

$ ->
  $(document).on('click', '.comment-time a#ajax_like', (e)->
    unless $(this).parent().hasClass("gap")
      path_href = $(this).attr('href')
      console.log("clicked LIKE")
      $.post path_href, (data) ->
        new_path = toggle(like, path_href)
        console.log(new_path)
        $(this).attr href: new_path
        $(this).attr text: "Unlike"
      e.preventDefault()
  )
  
$ ->
  $(document).on('click', '.comment-time a#ajax_unlike', (e)->
    unless $(this).parent().hasClass("gap")
      path_href = $(this).attr('href')
      console.log("clicked UNLIKE")
      $.post path_href, (data) ->
        new_path = toggle(unlike, path_href)
        console.log(new_path)
        $(this).attr href: new_path
        $(this).attr text: "Like"
      e.preventDefault()
  )
  
toggle = (mode, path) ->
  new_path = path
  if mode
    console.log("changing from like to unlike")
    new_path = new_path.replace /like/, "unlike"
    console.log(new_path)
  else
    console.log("changing from unlike to like")
    new_path = new_path.replace /unlike/, "like"
    console.log(new_path)
  new_path