import {approximate, exact, timeline} from '@/shared/helpers/format_time'

# this is a vue mixin
export default
  methods:
    scrollTo: (selector) -> @$vuetify.goTo(selector, duration: 0)
    approximateDate: (date) -> approximate(date)
    exactDate: (date) -> exact(date)
    timelineDate: (date) -> timeline(date)
