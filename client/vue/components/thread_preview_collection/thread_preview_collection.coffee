module.exports = Vue.component 'ThreadPreviewCollection',
  props:
    query: Object
    limit:
      type: Number
      default: 25
    order:
      type: String
      default: '-lastActivityAt'
  data: ->
    threads: @query.threads()
  computed:
    orderedThreads: ->
      _.slice(_.orderBy(@threads, @order), 0, @limit)
  template:
    """
    <div class="thread-previews">
      <div v-for="thread in orderedThreads" :key="thread.id" class="blank">
        <thread-preview :thread="thread"></thread-preview>
      </div>
    </div>
    """
