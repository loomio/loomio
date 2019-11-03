import DashboardPage from './components/dashboard/page.vue'
import InboxPage from './components/inbox/page.vue'
import ExplorePage from './components/explore/page.vue'
import ThreadPage from './components/thread/page.vue'
import ProfilePage from './components/profile/page.vue'
import PollPage from './components/poll/page.vue'

import GroupPage from './components/group/page.vue'
import GroupDiscussionsPanel from './components/group/discussions_panel'

import GroupPollsPanel from './components/group/polls_panel'

import MembersPanel from './components/group/members_panel'
import GroupSubgroupsPanel from './components/group/subgroups_panel'
import GroupFilesPanel from './components/group/files_panel'
import MembersTabs from './components/group/members_tabs'
import InvitationsPanel from './components/group/invitations_panel'
import MembershipRequestsPanel from './components/group/requests_panel'
import GroupSettingsPanel from './components/group/settings_panel'

import StartGroupPage from './components/start_group/page.vue'
import ContactPage from './components/contact/page.vue'
import EmailSettingsPage from './components/email_settings/page.vue'
import StartDiscussionPage from './components/start_discussion/page.vue'
import UserPage from './components/user/page.vue'
import InstallSlackPage from './components/install_slack/page.vue'

# import ActivityPanel from './components/thread/activity_panel'
# import ThreadPollsPanel from './components/thread/polls_panel'
# import ThreadMembersPanel from './components/thread/members_panel'
import ThreadNav from './components/thread/nav'

import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)

groupPageChildren = [
  {path: 'polls', component: GroupPollsPanel}
  {path: 'members', component: MembersTabs, children: [
    {path: '', component: MembersPanel}
    {path: 'invitations', component: InvitationsPanel}
    {path: 'requests', component: MembershipRequestsPanel}
    ]}
  {path: 'subgroups', component: GroupSubgroupsPanel}
  {path: 'files', component: GroupFilesPanel}
  {path: 'membership_requests', redirect: 'members/requests' }
  {path: 'settings', component: GroupSettingsPanel}
  {path: ':stub?', component: GroupDiscussionsPanel}
  {path: 'slack/install', component: InstallSlackPage}
]

threadPageChildren = [
  {path: 'comment/:comment_id', components: {nav: ThreadNav}}
  {path: ':stub?/:sequence_id?', components: {nav: ThreadNav}}
  {path: '', components: {nav: ThreadNav}}
]


export default new Router
  mode: 'history',
  routes: [
    {path: '/dashboard', component: DashboardPage},
    {path: '/dashboard/:filter', component: DashboardPage},
    {path: '/inbox', component: InboxPage },
    {path: '/explore', component: ExplorePage},
    {path: '/profile', component: ProfilePage},
    {path: '/contact', component: ContactPage},
    {path: '/email_preferences', component: EmailSettingsPage },
    {path: '/p/:key/:stub?', component: PollPage},
    {path: '/u/:key/:stub?', component: UserPage },
    {path: '/d/new', component: StartDiscussionPage },
    {path: '/d/:key', name: 'discussion', component: ThreadPage, children: threadPageChildren },
    {path: '/g/new', component: StartGroupPage},
    {path: '/g/:key', component: GroupPage, children: groupPageChildren},
    {path: '/:key', component: GroupPage, children: groupPageChildren},
    {path: '/', redirect: '/dashboard' }
  ]
