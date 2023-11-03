export var getEmbedLink = function(link) {
  link = link || "";
  if (link.includes("youtube.com") || link.includes("youtu.be")) {
    return getYoutubeEmbedLink(link);
  } else if (link.includes("vimeo.com/")) {
    return getVimeoEmbedLink(link);
  } else if (link.includes("loom.com")) {
    return getLoomEmbedLink(link);
  } else {
    return link;
  }
};

var getYoutubeEmbedLink = function(link) {
  const id = getYoutubeId(link);
  return `https://www.youtube.com/embed/${id}`;
};

var getVimeoEmbedLink = function(link) {
  if (link.includes("player.vimeo.com/video/")) {
    return link;
  } else {
    return link.replace("vimeo.com/", "player.vimeo.com/video/");
  }
};

var getYoutubeId = function(url) {
  // https://gist.github.com/takien/4077195
  let id = '';
  url = url.replace(/(>|<)/gi,'').split(/(vi\/|v=|\/v\/|youtu\.be\/|\/embed\/)/);

  if (url[2] !== undefined) {
    id = url[2].split(/[^0-9a-z_\-]/i);
    id = id[0];
  } else {
    id = url;
  }
  return id;
};

var getLoomEmbedLink = function(link) {
  if (link.includes("share")) {
    return link.replace("share", "embed");
  } else {
    return link;
  }
};
