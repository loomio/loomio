module.exports = Vue.component 'ThreadPreviewCollection',
  props:
    query: Object
    limit: Number
    order: {
      type: String
      default: '-lastActivityAt'
    }
  computed:
    orderedThreads: ->
      _.slice(_.orderBy(@query.threads(), @order), @limit)
  template:
    """
    <div class="thread-previews">
      <div v-for="thread in orderedThreads" :key="thread.id" class="blank">
        <thread-preview :thread="thread"></thread-preview>
      </div>
    </div>
    """
