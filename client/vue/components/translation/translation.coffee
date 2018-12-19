module.exports =
  props:
    model: Object
    field: String
  computed:
    translated: ->
      @model.translation[@field]
  template:
    """
    <div class="translation">
      <div v-marked="translated" class="translation__body"></div>
    </div>
    """
