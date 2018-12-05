AppConfig       = require 'shared/services/app_config'
Session         = require 'shared/services/session'
AbilityService  = require 'shared/services/ability_service'
ModalService    = require 'shared/services/modal_service'
ScrollService   = require 'shared/services/scroll_service'
I18n            = require 'shared/services/i18n'

{ viewportSize } = require 'shared/helpers/window'

module.exports =
  scrollTo: (target, options) -> scrollTo(target, options)
  updateCover:                -> updateCover()

  setCurrentComponent: (options) ->
    title = _.truncate(options.title or I18n.t(options.titleKey), {length: 300})
    document.querySelector('title').text = _.compact([title, AppConfig.theme.site_name]).join(' | ')

    AppConfig.currentGroup      = options.group
    AppConfig.currentDiscussion = options.discussion
    AppConfig.currentPoll       = options.poll

    ModalService.forceSignIn() if shouldForceSignIn(options)

    scrollTo(options.scrollTo or 'h1') unless options.skipScroll
    updateCover()

shouldForceSignIn = (options = {}) ->
  # TODO review before we merge into master
  # return false if options.page == "pollPage" and Session.user() !AbilityService.isEmailVerified()
  # return false if AbilityService.isEmailVerified()
  return false if AbilityService.isLoggedIn() && AppConfig.pendingIdentity.identity_type != "loomio"
  return true  if AppConfig.pendingIdentity.identity_type?
  switch options.page
    when 'emailSettingsPage' then !Session.user().restricted?
    when 'dashboardPage',      \
         'inboxPage',          \
         'profilePage',        \
         'authorizedAppsPage', \
         'registeredAppsPage', \
         'registeredAppPage',  \
         'pollsPage',          \
         'pollPage',           \
         'startPollPage',      \
         'upgradePage',        \
         'startGroupPage' then true

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
