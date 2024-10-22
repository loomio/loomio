<script lang="js">
import UrlFor from '@/mixins/url_for';
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import AbilityService from '@/shared/services/ability_service';
import WatchRecords from '@/mixins/watch_records';

export default {
  mixins: [UrlFor, WatchRecords],
  props: ['discussionsGroup', 'discussions', 'openCounts'],
  computed: {
    organization() {
      return this.discussionsGroup && this.discussionsGroup.parentOrSelf();
    },
    canStartThread() {
      return this.discussionsGroup && AbilityService.canStartThread(this.discussionsGroup);
    },
  }
}

</script>

<template lang="pug">
v-list(nav )
  //- template(v-if="!discussionsGroup")
  //-   v-list-item(to="/dashboard")
  //-     v-list-item-title
  //-       span(v-t="'dashboard_page.aria_label'")
  //- template(v-else)
  template(v-if="discussionsGroup")
    v-list-item(:to="urlFor(organization)")
      template(v-slot:prepend)
        group-avatar.mr-4(:group="organization")
      v-list-item-title
        span {{organization.name}}
        template(v-if='openCounts[organization.id]')
          | &nbsp;
          span ({{openCounts[organization.id]}})
    v-list-item(v-if="discussionsGroup.id != organization.id" :to="urlFor(discussionsGroup)")
      v-list-item-title
        span {{discussionsGroup.name}}
        template(v-if='openCounts[discussionsGroup.id]')
          | &nbsp;
          span ({{openCounts[discussionsGroup.id]}})

    v-divider.my-2
    v-list-subheader Threads

  v-list-item(lines="one" v-for="discussion in discussions" :to="urlFor(discussion)")
    v-list-item-title {{discussion.title}}
    v-list-item-subtitle {{discussion.group().name}}

  v-btn.sidebar__list-item-button--start-thread(
    v-if='canStartThread'
    block
    variant="tonal"
    color="primary"
    :to="'/thread_templates/?group_id='+discussionsGroup.id"
  )
    span(v-t="'common.action.new_thread'")



</template>
