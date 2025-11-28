<script lang="js">
import Records       from '@/shared/services/records';
import Session       from '@/shared/services/session';
import LmoUrlService from '@/shared/services/lmo_url_service';
import EventBus      from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import DiscussionTemplateService from '@/shared/services/discussion_template_service';
import { compact } from 'lodash-es';
import WatchRecords from '@/mixins/watch_records';
import UrlFor from '@/mixins/url_for';
import { mdiCog } from '@mdi/js';

export default {
  mixins: [WatchRecords, UrlFor],

  data() {
    return {
      mdiCog,
      templates: [],
      actions: {},
      group: null,
      returnTo: Session.returnTo(),
      isSorting: false,
      showSettings: false
    };
  },

  mounted() {
    Records.discussionTemplates.fetch({
      params: {
        group_id: this.$route.query.group_id,
        per: 50
      }
    });

    this.watchRecords({
      key: `discussionTemplates${this.$route.query.group_id}`,
      collections: ['discussionTemplates'],
      query: () => this.query()
    });

    EventBus.$on('sortThreadTemplates', () => { return this.isSorting = true; });
    EventBus.$on('reloadThreadTemplates', () => { return this.query(); });
  },

  methods: {
    sortEnded() {
      this.isSorting = false;
      setTimeout(() => {
        const ids = this.templates.map(p => p.id || p.key);
        Records.remote.post('discussion_templates/positions', {group_id: this.group.id, ids});
      });
    },

    query() {
      this.group = Records.groups.findById(parseInt(this.$route.query.group_id));
      this.templates = Records.discussionTemplates.collection.chain().find({
        groupId: parseInt(this.$route.query.group_id),
        discardedAt: (this.showSettings && {$ne: null}) || null
      }).simplesort('position').data();

      if (this.group) {
        this.actions = {};
        this.templates.forEach((template, i) => {
          this.actions[i] = DiscussionTemplateService.actions(template, this.group);
        });
      }
    }
  },

  computed: {
    userIsAdmin() {
      return this.group && this.group.adminsInclude(Session.user());
    },

    breadcrumbs() {
      if (!this.group) { return []; }
      return compact([this.group.parentId && this.group.parent(), this.group]).map(g => {
        return {
          title: g.name,
          disabled: false,
          to: this.urlFor(g)
        };
      });
    }
  },
  watch: {
    '$route.query': 'query',
    'showSettings': 'query'
  }
};
</script>
<template lang="pug">
.thread-templates-page
  v-main
    v-container.max-width-800.px-0.px-sm-3
      .d-flex
        v-breadcrumbs(color="anchor" :items="breadcrumbs")
          template(v-slot:divider)
            common-icon(name="mdi-chevron-right")
      v-card(:title="$t(showSettings ? 'discussion_template.hidden_templates' : 'discussion_template.start_a_new_discussion')")
        template(v-slot:append)
          v-btn(v-if="showSettings" icon @click="showSettings = false")
            common-icon(name="mdi-close")


        v-alert.mx-4(v-if="!showSettings && group && group.discussionsCount < 2" type="info" variant="tonal")
          span(v-t="'discussion_template.these_are_templates'")
          space
          help-link(path="en/user_manual/threads/starting_threads")

        v-list.append-sort-here(lines="two")
          .d-flex
            v-list-subheader(v-if="!showSettings" v-t="'templates.templates'")
            v-spacer
            div.mr-3(v-if="userIsAdmin")
              v-menu(v-if="!showSettings" offset-y)
                template(v-slot:activator="{props}")
                  v-btn(:icon="mdiCog" variant="flat" v-bind="props" :title="$t('common.admin_menu')")
                v-list
                  v-list-item(:to="'/thread_templates/new?group_id='+$route.query.group_id+'&return_to='+returnTo")
                    v-list-item-title(v-t="'discussion_form.new_template'")
                  v-list-item(@click="showSettings = true")
                    v-list-item-title(v-t="'discussion_template.hidden_templates'")

          template(v-if="isSorting")
            sortable-list(v-model:list="templates"  @sort-end="sortEnded" append-to=".append-sort-here"  lock-axis="y" axis="y")
              sortable-item(v-for="(template, index) in templates" :index="index" :key="template.id || template.key")
                v-list-item(:key="template.id")
                  v-list-item-title {{template.processName || template.title}}
                  v-list-item-subtitle {{template.processSubtitle}}
                  template(v-slot:append)
                    div.handle(style="cursor: grab")
                      common-icon(name="mdi-drag-vertical")

          template(v-if="!isSorting")
            v-list-item.thread-templates--template(
              v-for="(template, i) in templates"
              :key="template.id"
              :to="'/d/new?' + (template.id ? 'template_id='+template.id : 'template_key='+template.key)+ '&group_id='+ $route.query.group_id + '&return_to='+returnTo"
            )
              v-list-item-title {{template.processName || template.title}}
              v-list-item-subtitle {{template.processSubtitle}}
              template(v-slot:append)
                action-menu(:actions='actions[i]' size="small" icon :name="$t('action_dock.more_actions')")

      .d-flex.justify-center.my-2(v-if="!showSettings && userIsAdmin")
        v-btn(:to="'/thread_templates/browse?group_id=' + $route.query.group_id + '&return_to='+returnTo")
          span(v-t="'discussion_template.browse_public_templates'")
</template>
