<script lang="coffee">

import { groupPrivacy } from '@/shared/helpers/helptext'

export default
  props:
    group: Object
  computed:
    privacyDescription: -> @$t(groupPrivacy(@group))
    iconClass: ->
      switch @group.groupPrivacy
        when 'open'   then 'mdi-earth'
        when 'closed' then 'mdi-lock-outline'
        when 'secret' then 'mdi-lock-outline'
</script>

<template lang="pug">
v-tooltip(bottom)
  template(v-slot:activator="{on}")
    v-btn.group-privacy-button(icon v-on="on" :aria-label='privacyDescription')
      v-icon {{iconClass}}
      //- span(v-t="'common.privacy.' + group.groupPrivacy")
  | {{privacyDescription}}
</template>
