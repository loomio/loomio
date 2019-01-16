module.exports =
  props:
    group: Object
    setting: String
    translateValues: Boolean
  computed:
    translateKey: ->
      "group_form.#{_.snakeCase(@setting)}"
  template:
    """
    <div class="group-setting-checkbox">
      <v-checkbox v-model="group[setting]">
        <span v-t="{ path: translateKey, args: translateValues }"></span>
      </v-checkbox>
    </div>
    """
