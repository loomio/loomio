<script lang="js">
import Records        from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';
import LmoUrlService  from '@/shared/services/lmo_url_service';
import AuthModalMixin from '@/mixins/auth_modal';
import Session        from '@/shared/services/session';
import Flash        from '@/shared/services/flash';
import { I18n }           from '@/i18n';

export default {
  mixins: [AuthModalMixin],

  data() {
    return {
      group: null
    };
  },
  mounted() {
    if (!Session.isSignedIn()) { this.openAuthModal(); }

    if (this.$route.query.parent_id) {
      Records.groups.findOrFetch(parseInt(this.$route.query.parent_id)).then(parent => {
        this.group = Records.groups.build({parentId: parent.id});
      }).catch(error => {
        Flash.error('common.something_went_wrong');
        console.error(error);
      });
    } else {
      this.group = Records.groups.build({description: I18n.global.t('group_form.new_description_html')})
    }
  }
};
</script>

<template lang="pug">
v-main
  v-container.max-width-800.start-group-page.px-0.px-sm-3
    group-new-form(v-if="group" :group="group")
</template>
