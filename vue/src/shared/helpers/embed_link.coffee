export getEmbedLink = (link) ->
  if link.includes("youtube.com/")
    getYoutubeEmbedLink(link)
  else if link.includes("vimeo.com/")
    getVimeoEmbedLink(link)
  else
    link

getYoutubeEmbedLink = (link) ->
  if link.includes("youtube.com/embed/")
    link
  else if link.includes("youtube.com/watch?v=")
    link.replace("youtube.com/watch?v=", "youtube.com/embed/")
  else
    link

getVimeoEmbedLink = (link) ->
  if link.includes("player.vimeo.com/video/")
    link
  else
    link.replace("vimeo.com/", "player.vimeo.com/video/")
