(function() {
  $(function() {
    $('.main-container.container, .toolbar-navigation, .navbar.navbar-fixed-top').addClass('js-campaign');
    $('#js-banner').show();
    return $('#js-dismiss').click(function() {
      $('#js-banner').hide();
      $('.navbar-fixed-top').removeClass('js-campaign');
      $('.toolbar-navigation').removeClass('js-campaign');
      return $('.main-container.container').css('padding-top', '40px');
    });
  });

}).call(this);
