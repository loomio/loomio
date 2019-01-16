I18n = require 'shared/services/i18n'

{ groupPrivacy } = require 'shared/helpers/helptext'

module.exports =
  props:
    group: Object
  methods:
    privacyDescription: ->
      I18n.t groupPrivacy(@group)
  computed:
    iconClass: ->
      switch @group.groupPrivacy
        when 'open'   then 'mdi-earth'
        when 'closed' then 'mdi-lock-outline'
        when 'secret' then 'mdi-lock-outline'
  template:
    """
    <v-tooltip bottom class="group-privacy-button__tooltip">
      <button slot="activator" aria-label="{{privacyDescription()}}" class="group-privacy-button md-button">
        <div v-t="{ path: 'group_page.privacy.aria_label', args: { privacy: group.groupPrivacy }}" class="sr-only"></div>
        <div aria-hidden="true" class="screen-only lmo-flex lmo-flex__center">
          <i class="mdi" :class="iconClass"></i>
          <span v-t="'common.privacy.' + group.groupPrivacy"></span>
        </div>
      </button>
      {{privacyDescription()}}
    </v-tooltip>
    """
