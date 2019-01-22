<style lang="scss">
@import 'mixins';

.group-privacy-button i {
  margin-right: 4px;
  font-size: 18px;
}

.group-privacy-button__tooltip {
  max-width: 200px;
  text-align: center;
  @include fontSmall;
  font-style: italic;
  padding: 8px;
  margin-top: 4px !important;
  white-space: normal;
  height: auto;
  line-height: 20px;
}
</style>

<script lang="coffee">
I18n = require 'shared/services/i18n'

{ groupPrivacy } = require 'shared/helpers/helptext'

module.exports =
  props:
    group: Object
  computed:
    privacyDescription: -> I18n.t groupPrivacy(@group)
    iconClass: ->
      switch @group.groupPrivacy
        when 'open'   then 'mdi-earth'
        when 'closed' then 'mdi-lock-outline'
        when 'secret' then 'mdi-lock-outline'
</script>

<template>
    <v-tooltip bottom class="group-privacy-button__tooltip">
      <button slot="activator" :aria-label="privacyDescription" class="group-privacy-button md-button">
        <div v-t="{ path: 'group_page.privacy.aria_label', args: { privacy: group.groupPrivacy }}" class="sr-only"></div>
        <div aria-hidden="true" class="screen-only lmo-flex lmo-flex__center">
          <i class="mdi" :class="iconClass"></i>
          <span v-t="'common.privacy.' + group.groupPrivacy"></span>
        </div>
      </button>
      {{privacyDescription}}
    </v-tooltip>
</template>
