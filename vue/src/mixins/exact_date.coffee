export default
  methods:
    exactDate: (date) ->
      moment(date).format('dddd MMMM Do [at] h:mm a')
