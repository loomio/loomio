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
        @$vuetify.goTo(selector, duration: 200)
        setTimeout =>
          @$vuetify.goTo(selector, duration: 200)
          callback() if callback
        , 1000
    approximateDate: (date) -> approximate(date)
    exactDate: (date) -> exact(date)
    timelineDate: (date) -> timeline(date)
