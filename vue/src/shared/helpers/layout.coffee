import AppConfig        from '@/shared/services/app_config'
import Session          from '@/shared/services/session'
import AbilityService   from '@/shared/services/ability_service'
import ModalService     from '@/shared/services/modal_service'
import { viewportSize } from '@/shared/helpers/window'

export scrollTo = (target, options) ->
  setTimeout ->
    ScrollService.scrollTo(
      document.querySelector(target),
      document.querySelector(options.container or '.lmo-main-content'),
      options
    )
    
export updateCover = ->
  $cover = document.querySelector('.lmo-main-background')
  if AppConfig.currentGroup
    url = AppConfig.currentGroup.coverUrl(viewportSize())
    $cover.setAttribute('style', "background-image: url(#{url})")
  else
    $cover.removeAttribute('style')

export setCurrentComponent = (options) ->
  title = _.truncate(options.title or I18n.t(options.titleKey), {length: 300})
  document.querySelector('title').text = _.compact([title, AppConfig.theme.site_name]).join(' | ')

  AppConfig.currentGroup      = options.group
  AppConfig.currentDiscussion = options.discussion
  AppConfig.currentPoll       = options.poll

  ModalService.forceSignIn() if shouldForceSignIn(options)

  scrollTo(options.scrollTo or 'h1') unless options.skipScroll
  updateCover()

export shouldForceSignIn = (options = {}) ->
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
