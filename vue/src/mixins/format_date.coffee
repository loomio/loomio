import {approximate, exact, timeline} from '@/shared/helpers/format_time'

# this is a vue mixin
export default
  methods:
    scrollTo: (selector, callback) ->
      waitFor = (selector, fn) ->
        if document.querySelector(selector)
          fn()
        else
          # console.log 'waiting for ', selector
          setTimeout ->
            waitFor(selector, fn)
          , 500

      waitFor selector, =>
        @$vuetify.goTo(selector, duration: 0)
        callback() if callback
    approximateDate: (date) -> approximate(date)
    exactDate: (date) -> exact(date)
    timelineDate: (date) -> timeline(date)
