<script lang="js">
import { differenceInDays, format, parseISO } from 'date-fns';
import Session         from '@/shared/services/session';
import AuthModalMixin      from '@/mixins/auth_modal';
import Flash              from '@/shared/services/flash';
import Records            from '@/shared/services/records';
export default
{
  mixins: [ AuthModalMixin ],
  props: {
    group: Object
  },

  data() {
    return {loading: false};
  },

  methods: {
    signIn() { return this.openAuthModal(); },
    cloneDemo() { 
      this.loading = true;
      Flash.wait('templates.generating_demo');
      Records.post({
        path: 'demos/clone',
        params: {
          handle: this.group.handle
        }}).then(data => {
        Flash.success('templates.demo_created');
        this.$router.push(this.urlFor(Records.groups.find(data.groups[0].id)));
      }).finally(() => {
        this.loading = false;
      });
    }
  },

  computed: {
    isLoggedIn() { return Session.isSignedIn(); },
    isPublicDemo() { return !!this.group.handle; },
    isDemo() {
      return this.group.subscription.plan === 'demo';
    },
    daysRemaining() {
      return differenceInDays(parseISO(this.group.subscription.expires_at), new Date) + 1;
    },
    createdDate() {
      return format(new Date(this.group.createdAt), 'do LLLL yyyy');
    }
  }
};
</script>
<template>

<div>
  <v-overlay :value="loading"></v-overlay>
  <v-alert outlined="outlined" color="primary" dense="dense" v-if="isDemo">
    <template v-if="!isLoggedIn">
      <div class="text-center"><span v-t="'templates.login_to_start_demo'"></span><br/><span v-t="'templates.sign_in_to_try_features'"></span></div>
    </template>
    <template v-if="isLoggedIn && isPublicDemo">
      <div class="d-flex align-center"><span v-t="'templates.click_button_to_start_demo'"></span>
        <v-spacer></v-spacer>
        <v-btn class="ml-2" color="primary" @click="cloneDemo" target="_blank"><span v-t="'templates.start_demo'"></span></v-btn>
      </div>
    </template>
    <template v-if="isLoggedIn && !isPublicDemo">
      <div class="text-center">
        <p><span v-t="'templates.welcome_to_your_demo'"></span>
          <space></space><span v-t="'templates.try_voting_to_see_it_work'"></span><br/><span v-t="'templates.to_use_loomio_with_your_org_start_trial'"></span>
        </p>
        <v-btn outlined="outlined" color="primary" to="/g/new" target="_blank"><span v-t="'templates.start_free_trial'"></span></v-btn>
      </div>
    </template>
  </v-alert>
</div>
</template>
