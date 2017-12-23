module.exports =
  viewportSize: ->
    if window.innerWidth < 480
      'small'
    else if window.innerWidth < 992
      'medium'
    else
      'large'

  hardReload: (path) ->
    if path
      window.location.href = path
    else
      window.location.reload()

  scrollTo: (target, options = {}) ->
    setTimeout ->
      elem      = document.querySelector(target)
      container = document.querySelector(options.container or '.lmo-main-content')
      if options.bottom
          options.offset = document.documentElement.clientHeight - (options.offset or 100)
      if elem && container
        angular.element(container).scrollToElement(elem, options.offset or 50, options.speed or 100).then ->
          angular.element(window).triggerHandler('checkInView')
        elem.focus()

  trackEvents: ($scope) ->
    return unless ahoy?

    ahoy.trackClicks()
    ahoy.trackSubmits()
    ahoy.trackChanges()

    # track page views
    $scope.$on 'currentComponent', =>
      ahoy.track '$view',
        page:  window.location.pathname
        url:   window.location.href
        title: document.title

    # track modal views
    $scope.$on 'modalOpened', (_, modal) =>
      ahoy.track 'modalOpened',
        name: modal.templateUrl.match(/(\w+)\.html$/)[1]
