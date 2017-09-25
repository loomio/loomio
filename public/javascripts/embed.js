(function() {
  var Loomio = window.Loomio || {};
  if (!Loomio.pollKey || !Loomio.host) { return console.warn("WARN: Could not embed Loomio! Please check your embed code.") }

  var element        = document.getElementById('loomio-poll-' + Loomio.pollKey);
  var src            = Loomio.host + 'p/' + Loomio.pollKey + '/embed'
  var iframe         = document.createElement('iframe');
  iframe.src         = src;
  iframe.id          = 'loomio-frame-' + Loomio.pollKey;
  iframe.width       = "100%";
  iframe.style       = "min-height: 500px;";
  iframe.frameBorder = "0";
  iframe.class       = "loomio-embedded-iframe";
  iframe.scrolling   = "yes";
  element.appendChild(iframe);
})();
