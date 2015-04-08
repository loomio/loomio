angular.module('loomioApp').directive 'flash', ->
  scope: {modal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/flash/flash.html'
  replace: true
  controllerAs: 'flash'
  controller: ($scope, $timeout, FlashService) ->
    @pendingDismiss = null

    $scope.$on 'flashMessage', (event, flash) =>
      @flash = flash
      $timeout.cancel @pendingDismiss if @pendingDismiss?
      @pendingDismiss = $timeout @dismiss, 2000

    @modalIsVisible = ->
      angular.element('.modal').hasClass('in')

    @display = => @flash and (@modal == @modalIsVisible())
    @dismiss = => @flash = null

    FlashService.success window.Loomio.flash.success if window.Loomio.flash.success?
    FlashService.info    window.Loomio.flash.notice  if window.Loomio.flash.notice?
    FlashService.warning window.Loomio.flash.warning if window.Loomio.flash.warning?
    FlashService.error   window.Loomio.flash.error   if window.Loomio.flash.error?

    return
