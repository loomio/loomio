import DashboardPage from './components/dashboard/page.vue'
import PollsPage from './components/polls/page.vue'
import InboxPage from './components/inbox/page.vue'
import ExplorePage from './components/explore/page.vue'
import ThreadPage from './components/thread/page.vue'
import ProfilePage from './components/profile/page.vue'
import StartPollPage from './components/start_poll/page.vue'
import PollPage from './components/poll/page.vue'
import MembershipRequestsPage from './components/membership_requests/page.vue'

import GroupPage from './components/group/page.vue'
import GroupDiscussionsPanel from './components/group/discussions_panel'
import GroupPollsPanel from './components/group/polls_panel'
import GroupMembersPanel from './components/group/members_panel'
import GroupSubgroupsPanel from './components/group/subgroups_panel'
import GroupFilesPanel from './components/group/files_panel'

import StartGroupPage from './components/start_group/page.vue'
import ContactPage from './components/contact/page.vue'
import EmailSettingsPage from './components/email_settings/page.vue'
import StartDiscussionPage from './components/start_discussion/page.vue'
import UserPage from './components/user/page.vue'
import AuthorizedAppsPage from './components/authorized_apps/page.vue'
import RegisteredAppsPage from './components/registered_apps/page.vue'
import RegisteredAppPage from './components/registered_app/page.vue'
import InstallSlackPage from './components/install_slack/page.vue'

import ActivityPanel from './components/thread/activity_panel'
import ThreadPollsPanel from './components/thread/polls_panel'
import ThreadMembersPanel from './components/thread/members_panel'
import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)

groupPageChildren = [
  {path: '', component: GroupDiscussionsPanel},
  {path: 'polls', component: GroupPollsPanel},
  {path: 'members', component: GroupMembersPanel},
  {path: 'subgroups', component: GroupSubgroupsPanel}
  {path: 'files', component: GroupFilesPanel},
]

threadPageChildren = [
  {path: 'polls', component: ThreadPollsPanel}
  {path: 'members', component: ThreadMembersPanel}
  {path: 'comment/:comment_id', component: ActivityPanel}
  {path: ':stub?/:sequence_id?', component: ActivityPanel}
  {path: '', component: ActivityPanel}
]


export default new Router
  mode: 'history',
  routes: [
    {path: '/dashboard', component: DashboardPage},
    {path: '/dashboard/:filter', component: DashboardPage},
    {path: '/polls', component: PollsPage},
    {path: '/polls/:filter', component: PollsPage},
    {path: '/inbox', component: InboxPage },
    {path: '/explore', component: ExplorePage},
    {path: '/profile', component: ProfilePage},
    {path: '/contact', component: ContactPage},
    {path: '/email_preferences', component: EmailSettingsPage },
    {path: '/d/new', component: StartDiscussionPage },
    {path: '/d/:key', component: ThreadPage, children: threadPageChildren },
    # {path: '/d/:key', component: ThreadPage },
    # {path: '/d/:key/comment/:comment_id', component: ThreadPage},
    # {path: '/d/:key/:stub/:sequence_id', component: ThreadPage },
    {path: '/p/new', component: StartPollPage},
    {path: '/p/new/:poll_type', component: StartPollPage},
    {path: '/p/:key/:stub?', component: PollPage},
    {path: '/u/:key/:stub?', component: UserPage },
    {path: '/apps/authorized', component: AuthorizedAppsPage},
    {path: '/apps/registered', component: RegisteredAppsPage},
    {path: '/apps/registered/:id', component: RegisteredAppPage},
    {path: '/apps/registered/:id/:stub', component: RegisteredAppPage},
    {path: '/slack/install', component: InstallSlackPage},
    {path: '/g/new', component: StartGroupPage},
    {path: '/g/:key/membership_requests', component: MembershipRequestsPage},
    {path: '/g/:key/:tab?', component: GroupPage, children: groupPageChildren},
    # key is actually handle
    {path: '/:key/:tab', component: GroupPage, children: groupPageChildren},
    {path: '/:key', component: GroupPage, children: groupPageChildren},
    {path: '/', redirect: '/dashboard' }
  ]
