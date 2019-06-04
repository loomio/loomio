import AppConfig        from '@/shared/services/app_config'
import Session          from '@/shared/services/session'
import AbilityService   from '@/shared/services/ability_service'
import ModalService     from '@/shared/services/modal_service'
import { viewportSize } from '@/shared/helpers/window'

export scrollTo = (target, options) ->
  # setTimeout ->
  #   ScrollService.scrollTo(
  #     document.querySelector(target),
  #     document.querySelector(options.container or '.lmo-main-content'),
  #     options
  #   )

export updateCover = ->
  $cover = document.querySelector('.lmo-main-background')
  if AppConfig.currentGroup
    url = AppConfig.currentGroup.coverUrl(viewportSize())
    $cover.setAttribute('style', "background-image: url(#{url})")
  else
    $cover.removeAttribute('style')
