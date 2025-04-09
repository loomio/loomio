<script lang="js">
import Records        from '@/shared/services/records';
import Session        from '@/shared/services/session';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import AppConfig      from '@/shared/services/app_config';
import WatchRecords from '@/mixins/watch_records';
import { ContainerMixin, HandleDirective } from 'vue-slicksort';

export default {
  mixins: [WatchRecords],

  props: {
    group: {
      type: Object,
      required: true
    },
    close: Function
  },

  directives: {
    handle: HandleDirective
  },

  data() {
    return {allTags: this.group.tags()};
  },

  mounted() {
    this.watchRecords({
      key: 'tags'+this.group.id,
      collections: ['tags'],
      query: () => {
        return this.allTags = this.group.tags();
      }
    });
  },

  computed: {
    canAdminTags() {
      return this.group.adminsInclude(Session.user());
    }
  },

  methods: {
    query() {
      this.allTags = this.group.tags();
    },

    openNewTagModal() {
      EventBus.$emit('openModal', {
        component: 'TagsModal',
        props: {
          tag: Records.tags.build({groupId: this.group.id}),
          close: () => {
            EventBus.$emit('openModal', {
              component: 'TagsSelect',
              props: {
                group: this.group
              }
            });
          }
        }
      });
    },

    openEditTagModal(tag) {
      EventBus.$emit('openModal', {
        component: 'TagsModal',
        props: {
          tag: tag.clone(),
          close: () => {
            EventBus.$emit('openModal', {
              component: 'TagsSelect',
              props: {
                group: this.group
              }
            });
          }
        }
      });
    },

    submit() {
      EventBus.$emit('closeModal');
    },

    sortEnded() {
      setTimeout(() => {
        Records.remote.post('tags/priority', {
          group_id: this.group.id,
          ids: this.allTags.map(t => t.id)
        });
      });
    }
  }
};

</script>
<template lang="pug">
v-card.tags-modal(:title="$t('loomio_tags.card_title')")
  template(v-slot:append)
    dismiss-modal-button(:close="close")

  .px-4.pb-2
    p.text-medium-emphasis
      span(v-if="canAdminTags" v-t="'loomio_tags.helptext'")
      span(v-else v-t="{path: 'loomio_tags.only_admins_can_edit_tags', args: {group: group.parentOrSelf().name}}")

  div(v-if="canAdminTags")
    .pa-4(v-if="allTags.length == 0")
      p.text-medium-emphasis(v-t="'loomio_tags.no_tags_in_group'")
    sortable-list(
      v-model:list="allTags"
      useDragHandle
      @sort-end="sortEnded"
      append-to=".app-is-booted"
      lock-axis="y"
      axis="y"
    )
      sortable-item(v-for="(tag, index) in allTags" :index="index" :key="tag.id")
        v-list-item
          template(v-slot:prepend)
            .handle(v-handle)
              common-icon(name="mdi-drag-vertical")
          v-chip(:color="tag.color" v-handle outlined) {{tag.name}}
          template(v-slot:append)
            v-btn(icon variant="text" @click="openEditTagModal(tag)")
              common-icon.text-medium-emphasis(name="mdi-pencil")

  v-card-actions(v-if="canAdminTags")
    v-spacer
    v-btn.tag-form__new-tag(variant="elevated" color="primary" @click="openNewTagModal")
      span(v-t="'loomio_tags.new_tag'")
</template>
