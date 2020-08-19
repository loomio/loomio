import {approximate, exact, timeline} from '@/shared/helpers/format_time'
import EventBus from '@/shared/services/event_bus'
import {each} from 'lodash'

# this is a vue mixin
export default
  methods:
    titleVisible: (visible) ->
      EventBus.$emit('content-title-visible', visible)

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
        each [1,2,3], (n) =>
          headingSelector = selector+" h#{n}[tabindex=\"-1\"]"
          if document.querySelector(headingSelector)
            # console.log "focusing h#{n}", document.querySelector(selector+" h#{n}")
            document.querySelector(headingSelector).focus()
            return false
          else
            return true
        callback() if callback
    approximateDate: (date) -> approximate(date)
    exactDate: (date) -> exact(date)
    timelineDate: (date) -> timeline(date)
