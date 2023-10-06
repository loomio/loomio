import DashboardPage from './components/dashboard/page'
import InboxPage from './components/inbox/page'
import ExplorePage from './components/explore/page'
import ProfilePage from './components/profile/page'
import PollShowPage from './components/poll/show_page'
import PollFormPage from './components/poll/form_page'
import PollTemplateFormPage from './components/poll_template/form_page'
import TasksPage from './components/tasks/page'
import GroupPage from './components/group/page.vue'
import GroupDiscussionsPanel from './components/group/discussions_panel'
import GroupPollsPanel from './components/group/polls_panel'
import MembersPanel from './components/group/members_panel'
import GroupTagsPanel from './components/group/tags_panel'
import GroupSubgroupsPanel from './components/group/subgroups_panel'
import GroupFilesPanel from './components/group/files_panel'
import MembershipRequestsPanel from './components/group/requests_panel'
import StartGroupPage from './components/start_group/page'
import ContactPage from './components/contact/page'
import EmailSettingsPage from './components/email_settings/page'
import ThreadFormPage from './components/thread/form_page'
import UserPage from './components/user/page'
import ThreadsPage from './components/threads/page'
import StrandPage from './components/strand/page'
import DemosPage from './components/demos/index.vue'

import './config/catch_navigation_duplicated.js'
import Vue from 'vue'
import Router from 'vue-router'

import Session from '@/shared/services/session'

import RescueUnsavedEditsService from '@/shared/services/rescue_unsaved_edits_service'

Vue.use(Router)

groupPageChildren = [
  {path: 'tags/:tag?', component: GroupTagsPanel, meta: {noScroll: true} },
  {path: 'polls', component: GroupPollsPanel, meta: {noScroll: true}}
  {path: 'members', component: MembersPanel, meta: {noScroll: true}}
  {path: 'membership_requests', component: MembershipRequestsPanel, meta: {noScroll: true}}
  {path: 'members/requests', redirect: 'membership_requests', meta: {noScroll: true}}
  {path: 'subgroups', component: GroupSubgroupsPanel, meta: {noScroll: true}}
  {path: 'files', component: GroupFilesPanel, meta: {noScroll: true}}
  {path: ':stub?', component: GroupDiscussionsPanel, meta: {noScroll: true}}
]

router = new Router
  mode: 'history'

  scrollBehavior: (to, from, savedPosition) ->
    if savedPosition
      savedPosition
    else if (to.meta.noScroll and from.meta.noScroll)
      window.scrollHeight
    else
      { x: 0, y: 0 }

  routes: [
    {path: '/try', component: DemosPage},
    {path: '/users/sign_in', redirect: '/dashboard' },
    {path: '/users/sign_up', redirect: '/dashboard' },
    {path: '/tasks', component: TasksPage},
    {path: '/dashboard', component: DashboardPage},
    {path: '/dashboard/:filter', component: DashboardPage},
    {path: '/threads/direct', component: ThreadsPage},
    {path: '/inbox', component: InboxPage },
    {path: '/explore', component: ExplorePage},
    {path: '/profile', component: ProfilePage},
    {path: '/contact', component: ContactPage},
    {path: '/email_preferences', component: EmailSettingsPage },
    {path: '/p/:key/edit', component: PollFormPage },
    {path: '/p/new', component: PollFormPage },
    {path: '/p/:key/:stub?', component: PollShowPage},
    {path: '/poll_templates/new', component: PollTemplateFormPage},
    {path: '/poll_templates/:id/edit', component: PollTemplateFormPage},
    {path: '/u/:key/:stub?', component: UserPage },
    {path: '/d/new', component: ThreadFormPage },
    {path: '/d/:key/edit', component: ThreadFormPage },
    {
      path: '/d/:key',
      component: StrandPage,
      children: [
        {path: 'comment/:comment_id'}
        {path: ':stub?/:sequence_id?'}
        {path: ''}
      ]
    },
    {path: '/g/new', component: StartGroupPage},
    {path: '/g/:key', component: GroupPage, children: groupPageChildren, name: 'groupKey'},
    {path: '/:key', component: GroupPage, children: groupPageChildren},
    {path: '/', redirect: '/dashboard' }
  ]

router.beforeEach (to, from, next) ->
  if RescueUnsavedEditsService.okToLeave()
    next()
  else
    next(false)

router.afterEach ->
  RescueUnsavedEditsService.clear()

export default router
