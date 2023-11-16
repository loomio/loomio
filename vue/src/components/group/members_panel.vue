<script lang="js">
import Records        from '@/shared/services/records';
import AbilityService from '@/shared/services/ability_service';
import RecordLoader   from '@/shared/services/record_loader';
import Session        from '@/shared/services/session';
import EventBus       from '@/shared/services/event_bus';
import {includes, some, compact, intersection, orderBy, slice, debounce, min, escapeRegExp, map} from 'lodash-es';
import LmoUrlService from '@/shared/services/lmo_url_service';
import { exact, approximate } from '@/shared/helpers/format_time';

export default
{
  data() {
    return {
      loader: null,
      group: null,
      per: 25,
      order: 'created_at desc',
      orders: [
        {text: this.$t('members_panel.order_by_name'),  value:'users.name' },
        {text: this.$t('members_panel.order_by_created'), value:'memberships.created_at' },
        {text: this.$t('members_panel.order_by_created_desc'), value:'memberships.created_at desc' },
        {text: this.$t('members_panel.order_by_admin_desc'), value:'admin desc' }
      ],
      memberships: []
    };
  },

  created() {
    this.onQueryInput = debounce(val => {
      return this.$router.replace(this.mergeQuery({q: val}));
    }
    , 500);

    Records.groups.findOrFetch(this.$route.params.key).then(group => {
      this.group = group;

      EventBus.$emit('currentComponent', {
        page: 'groupPage',
        title: this.group.name,
        group: this.group,
        search: {
          placeholder: this.$t('navbar.search_members', {name: this.group.parentOrSelf().name})
        }
      }
      );

      this.loader = new RecordLoader({
        collection: 'memberships',
        params: {
          exclude_types: 'group',
          group_id: this.group.id,
          per: this.per,
          order: this.order,
          subgroups: this.$route.query.subgroups
        }
      });

      this.watchRecords({
        collections: ['memberships', 'groups'],
        query: this.query
      });

      this.refresh();
    });
  },

  methods: {
    exact,
    approximate,

    query() {
      let chain = Records.memberships.collection.chain();
      switch (this.$route.query.subgroups) {
        case 'mine':
          chain = chain.find({groupId: {$in: intersection(this.group.organisationIds(), Session.user().groupIds())}});
          break;
        case 'all':
          chain = chain.find({groupId: {$in: this.group.organisationIds()}});
          break;
        default:
          chain = chain.find({groupId: this.group.id});
      }

      chain = chain.sort((a, b) => {
        if (a.groupId === this.group.id) { return -1; }
        if (b.groupId === this.group.id) { return 1; }
        return 0;
      });

      const userIds = [];
      const membershipIds = [];
      chain.data().forEach(function(m) {
        if (!userIds.includes(m.userId)) {
          userIds.push(m.userId);
          return membershipIds.push(m.id);
        }
      });

      // @memberships = Records.memberships.collection.find(id: {$in: membershipIds})

      // drop the chain, get a new one

      chain = Records.memberships.collection.chain().find({id: {$in: membershipIds}});

      if (this.$route.query.q) {
        const users = Records.users.collection.find({
          $or: [
            {name: {'$regex': [`^${this.$route.query.q}`, "i"]}},
            {email: {'$regex': [`${this.$route.query.q}`, "i"]}},
            {username: {'$regex': [`^${this.$route.query.q}`, "i"]}},
            {name: {'$regex': [` ${this.$route.query.q}`, "i"]}}
          ]});
        chain = chain.find({userId: {$in: map(users, 'id')}});
      }

      switch (this.$route.query.filter) {
        case 'admin':
          chain = chain.find({admin: true});
          break;
        case 'accepted':
          chain = chain.find({acceptedAt: { $ne: null }});
          break;
        case 'pending':
          chain = chain.find({acceptedAt: null});
          break;
      }

      chain = chain.simplesort('id', true);

      this.memberships = chain.data();
    },

    refresh() {
      this.loader.fetchRecords({
        from: 0,
        q: this.$route.query.q,
        order: this.order,
        filter: this.$route.query.filter,
        subgroups: this.$route.query.subgroups
      });
      this.query();
    },

    invite() {
      EventBus.$emit('openModal', {
        component: 'GroupInvitationForm',
        props: {
          group: this.group
        }
      });
    }
  },

  computed: {
    membershipRequestsPath() { return LmoUrlService.membershipRequest(this.group); },
    showLoadMore() { return !this.loader.exhausted; },
    totalRecords() {
      if (this.pending) {
        return this.group.pendingMembershipsCount;
      } else {
        return this.group.membershipsCount - this.group.pendingMembershipsCount;
      }
    },

    canAddMembers() {
      return AbilityService.canAddMembersToGroup(this.group) && !this.pending;
    },

    showAdminWarning() {
      return this.group.adminsInclude(Session.user()) &&
      (this.group.adminMembershipsCount < 2) &&
      ((this.group.membershipsCount - this.group.adminMembershipsCount) > 0);
    }
  },

  watch: {
    '$route.query': 'refresh'
  }
};


</script>

<template lang="pug">
.members-panel
  loading(v-if="!group")
  div(v-if="group")
    v-alert.my-2(v-if="showAdminWarning" color="primary" type="warning")
      template(slot="default")
        span(v-t="'memberships_page.only_one_admin'")

    v-layout.py-2(align-center wrap)
      v-menu
        template(v-slot:activator="{ on, attrs }")
          v-btn.members-panel__filters.mr-2.text-lowercase(v-on="on" v-bind="attrs" text)
            span(v-if="$route.query.filter == 'admin'" v-t="'members_panel.order_by_admin_desc'")
            span(v-if="$route.query.filter == 'pending'" v-t="'members_panel.invitations'")
            span(v-if="$route.query.filter == 'accepted'" v-t="'members_panel.accepted'")
            span(v-if="!$route.query.filter" v-t="'members_panel.all'")
            v-icon mdi-menu-down
        v-list
          v-list-item.members-panel__filters-everyone(:to="mergeQuery({filter: null})")
            v-list-item-title(v-t="'members_panel.all'")
          v-list-item.members-panel__filters-everyone(:to="mergeQuery({filter: 'accepted'})")
            v-list-item-title(v-t="'members_panel.accepted'")
          v-list-item.members-panel__filters-admins(:to="mergeQuery({filter: 'admin'})")
            v-list-item-title(v-t="'members_panel.order_by_admin_desc'")
          v-list-item.members-panel__filters-invitations(:to="mergeQuery({filter: 'pending'})")
            v-list-item-title(v-t="'members_panel.invitations'")
      v-text-field.mr-2(clearable hide-details solo :value="$route.query.q" @input="onQueryInput" :placeholder="$t('navbar.search_members', {name: group.name})" append-icon="mdi-magnify")
      v-btn.membership-card__invite.mr-2(color="primary" v-if='canAddMembers' @click="invite()" v-t="'common.action.invite'")
      shareable-link-modal(v-if='canAddMembers' :group="group")
      v-btn.group-page__requests-tab(
        v-if='group.isVisibleToPublic && canAddMembers'
        :to="urlFor(group, 'members/requests')"
        color="primary"
        outlined
        v-t="'members_panel.requests'")

    v-card(outlined)
      div(v-if="loader.status == 403")
        p.pa-4.text-center(v-t="'error_page.forbidden'")
      div(v-else)
        p.pa-4.text-center(v-if="!memberships.length" v-t="'common.no_results_found'")
        v-list(v-else two-line)
          v-list-item(v-for="membership in memberships" :key="membership.id")
            v-list-item-avatar(size='48')
              router-link(:to="urlFor(membership.user())")
                user-avatar(:user='membership.user()' :size='48')
            v-list-item-content
              v-list-item-title
                router-link(:to="urlFor(membership.user())") {{ membership.user().name }}
                span
                span.text--secondary
                  space
                  span(v-if="membership.acceptedAt && membership.userEmail") <{{membership.userEmail}}>
                  span(v-else) {{membership.userEmail}}
                space
                span.caption(v-if="$route.query.subgroups") {{membership.group().name}}
                space
                span.title.caption {{membership.user().title(group)}}
                space
                v-chip(v-if="membership.user().bot" x-small outlined label v-t="'members_panel.bot'")
                span(v-if="membership.groupId == group.id && membership.admin")
                  space
                  v-chip(x-small outlined label v-t="'members_panel.admin'")
                  space
                span.caption.text--secondary(v-if="membership.acceptedAt")
                  span(v-t="'common.action.joined'")
                  space
                  time-ago(:date="membership.acceptedAt")
                span.caption.text--secondary(v-if="!membership.acceptedAt")
                  template(v-if="membership.inviterId")
                    span(v-t="{path: 'members_panel.invited_by_name', args: {name: membership.inviter().name}}")
                    space
                    time-ago(:date="membership.createdAt")
                  template(v-if="!membership.inviterId")
                    span(v-t="'members_panel.header_invited'")
                    space
                    time-ago(:date="membership.createdAt")
              v-list-item-subtitle
                span(v-if="membership.acceptedAt") {{ (membership.user().shortBio || '').replace(/<\/?[^>]+(>|$)/g, "") }}
            v-list-item-action
              membership-dropdown(v-if="membership.groupId == group.id" :membership="membership")

        .d-flex.justify-center
          .d-flex.flex-column.align-center
            .text--secondary(v-if='$route.query.subgroups == "all"')
              | {{memberships.length}} / {{group.orgMembersCount}}
            .text--secondary(v-else)
              | {{memberships.length}} / {{loader.total}}
            v-btn.my-2.members-panel__show-more(outlined color='primary' v-if="memberships.length < loader.total && !loader.exhausted" :loading="loader.loading" @click="loader.fetchRecords({per: 50})")
              span(v-t="'common.action.load_more'")
            a(v-if='group.subgroupsCount && $route.query.subgroups != "all"' href="?subgroups=all" v-t="'members_panel.show_users_in_subgroups'") show users in all subgroups

</template>
