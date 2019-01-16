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
      <!-- <md-checkbox ng-model="group[setting]">
        <span translate="{{translateKey()}}" translate-values="translateValues"></span>
      </md-checkbox> -->
    </div>
    """
