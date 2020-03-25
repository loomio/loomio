export getEmbedLink = (link) ->
  if link.includes("youtube.com") || link.includes("youtu.be")
    getYoutubeEmbedLink(link)
  else if link.includes("vimeo.com/")
    getVimeoEmbedLink(link)
  else if link.includes("loom.com")
    getLoomEmbedLink(link)
  else
    link

getYoutubeEmbedLink = (link) ->
  id = getYoutubeId(link)
  "https://www.youtube.com/embed/#{id}"

getVimeoEmbedLink = (link) ->
  if link.includes("player.vimeo.com/video/")
    link
  else
    link.replace("vimeo.com/", "player.vimeo.com/video/")

getYoutubeId = (url) ->
  # https://gist.github.com/takien/4077195
  id = ''
  url = url.replace(/(>|<)/gi,'').split(/(vi\/|v=|\/v\/|youtu\.be\/|\/embed\/)/)

  if url[2] != undefined
    id = url[2].split(/[^0-9a-z_\-]/i)
    id = id[0]
  else
    id = url
  return id

getLoomEmbedLink = (link) ->
  if link.includes("share")
    link.replace("share", "embed")
  else
    link
