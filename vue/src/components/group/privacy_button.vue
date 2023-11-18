<script lang="js">
import { groupPrivacy } from '@/shared/helpers/helptext';

export default
{
  props: {
    group: Object
  },
  computed: {
    privacyDescription() { return this.$t(groupPrivacy(this.group)); },
    iconClass() {
      switch (this.group.groupPrivacy) {
        case 'open':   return 'mdi-earth';
        case 'closed': return 'mdi-lock-outline';
        case 'secret': return 'mdi-lock-outline';
      }
    }
  }
};
</script>

<template lang="pug">
v-tooltip(bottom)
  template(v-slot:activator="{on, attrs}")
    v-btn.group-privacy-button(icon v-on="on" v-bind="attrs" :aria-label='privacyDescription')
      common-icon(:name="iconClass")
      //- span(v-t="'common.privacy.' + group.groupPrivacy")
  | {{privacyDescription}}
</template>
