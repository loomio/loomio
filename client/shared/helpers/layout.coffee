AppConfig       = require 'shared/services/app_config.coffee'
AbilityService  = require 'shared/services/ability_service.coffee'
ModalService    = require 'shared/services/modal_service.coffee'
IntercomService = require 'shared/services/intercom_service.coffee'
ScrollService   = require 'shared/services/scroll_service.coffee'
I18n            = require 'shared/services/i18n.coffee'

{ viewportSize } = require 'shared/helpers/window.coffee'

module.exports =
  scrollTo: (target, options) -> scrollTo(target, options)
  updateCover:                -> updateCover()

  setCurrentComponent: (options) ->
    title = _.trunc options.title or I18n.t(options.titleKey), 300
    document.querySelector('title').text = _.compact([title, AppConfig.theme.site_name]).join(' | ')

    AppConfig.currentGroup = options.group
    IntercomService.updateWithGroup(AppConfig.currentGroup)
    ModalService.forceSignIn() if AbilityService.requireLoginFor(options.page) or (AppConfig.pendingIdentity or {}).identity_type

    scrollTo(options.scrollTo or 'h1') unless options.skipScroll
    updateCover()

updateCover = ->
  $cover = document.querySelector('.lmo-main-background')
  if AppConfig.currentGroup
    url = AppConfig.currentGroup.coverUrl(viewportSize())
    $cover.setAttribute('style', "background-image: url(#{url})")
  else
    $cover.removeAttribute('style')

scrollTo = (target, options = {}) ->
  setTimeout ->
    ScrollService.scrollTo(
      document.querySelector(target),
      document.querySelector(options.container or '.lmo-main-content'),
      options
    )
