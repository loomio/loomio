module.exports = Vue.component 'TimeAgo',
  params: ['date']
  template: '<abbr class="timeago"><span>{{ ago }}</span></abbr>'
  computed:
    ago: ->
      moment(@date).fromNow()
