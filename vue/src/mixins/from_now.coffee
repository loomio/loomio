import * as moment from 'moment'

export default
  methods:
    fromNow: (date) ->
      moment(date).fromNow()
