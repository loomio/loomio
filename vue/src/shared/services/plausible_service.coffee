import Plausible from 'plausible-tracker'
import AppConfig from '@/shared/services/app_config'

plausible = null

export default new class PlausibleService
  boot: ->
    if AppConfig.plausible_site
      u = new URL(AppConfig.plausible_src)
      plausible = Plausible({
        domain: AppConfig.plausible_site
        apiHost: u.origin
        trackLocalhost: true
      })

  trackPageview: ->
    if plausible
      plausible.trackPageview()

  trackEvent: (name) ->
    if plausible
      plausible.trackEvent(name)
