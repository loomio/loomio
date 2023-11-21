import DashboardPage from './components/dashboard/page';
import GroupPage from './components/group/page.vue';
import StrandPage from './components/strand/page';

const InboxPage = () => import('./components/inbox/page');
const ExplorePage = () => import('./components/explore/page');
const ProfilePage = () => import('./components/profile/page');
const PollShowPage = () => import('./components/poll/show_page');
const PollFormPage = () => import('./components/poll/form_page');
const PollTemplateFormPage = () => import('./components/poll_template/form_page');
const TasksPage = () => import('./components/tasks/page');
const GroupDiscussionsPanel = () => import('./components/group/discussions_panel');
const GroupPollsPanel = () => import('./components/group/polls_panel');
const MembersPanel = () => import('./components/group/members_panel');
const GroupTagsPanel = () => import('./components/group/tags_panel');
const GroupSubgroupsPanel = () => import('./components/group/subgroups_panel');
const GroupFilesPanel = () => import('./components/group/files_panel');
const MembershipRequestsPanel = () => import('./components/group/requests_panel');
const StartGroupPage = () => import('./components/start_group/page');
const ContactPage = () => import('./components/contact/page');
const EmailSettingsPage = () => import('./components/email_settings/page');
const ThreadFormPage = () => import('./components/thread/form_page');
const ThreadTemplateFormPage = () => import('./components/thread_template/form_page');
const ThreadTemplateIndexPage = () => import('./components/thread_template/index_page');
const ThreadTemplateBrowsePage = () => import('./components/thread_template/browse_page');
const UserPage = () => import('./components/user/page');
const ThreadsPage = () => import('./components/threads/page');
const DemosPage = () => import('./components/demos/index.vue');

import './config/catch_navigation_duplicated.js';
import Vue from 'vue';
import Router from 'vue-router';

import Session from '@/shared/services/session';

import RescueUnsavedEditsService from '@/shared/services/rescue_unsaved_edits_service';

Vue.use(Router);

const groupPageChildren = [
  {path: 'tags/:tag?', component: GroupTagsPanel, meta: {noScroll: true} },
  {path: 'polls', component: GroupPollsPanel, meta: {noScroll: true}},
  {path: 'members', component: MembersPanel, meta: {noScroll: true}},
  {path: 'membership_requests', component: MembershipRequestsPanel, meta: {noScroll: true}},
  {path: 'members/requests', redirect: 'membership_requests', meta: {noScroll: true}},
  {path: 'subgroups', component: GroupSubgroupsPanel, meta: {noScroll: true}},
  {path: 'files', component: GroupFilesPanel, meta: {noScroll: true}},
  {path: ':stub?', component: GroupDiscussionsPanel, meta: {noScroll: true}}
];

const router = new Router({
  mode: 'history',

  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition;
    } else if (to.meta.noScroll && from.meta.noScroll) {
      return window.scrollHeight;
    } else {
      return { x: 0, y: 0 };
    }
  },

  routes: [
    {path: '/demo', component: DemosPage},
    {path: '/try', redirect: '/g/new'},
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
    {path: '/thread_templates/browse', component: ThreadTemplateBrowsePage },
    {path: '/thread_templates/new', component: ThreadTemplateFormPage },
    {path: '/thread_templates/:id', component: ThreadTemplateFormPage },
    {path: '/thread_templates', component: ThreadTemplateIndexPage },
    {
      path: '/d/:key',
      component: StrandPage,
      children: [
        {path: 'comment/:comment_id'},
        {path: ':stub?/:sequence_id?'},
        {path: ''}
      ]
    },
    {path: '/g/new', component: StartGroupPage},
    {path: '/g/:key', component: GroupPage, children: groupPageChildren, name: 'groupKey'},
    {path: '/:key', component: GroupPage, children: groupPageChildren},
    {path: '/', redirect: '/dashboard' }
  ]});

router.beforeEach(function(to, from, next) {
  if (RescueUnsavedEditsService.okToLeave()) {
    return next();
  } else {
    return next(false);
  }
});

router.afterEach(() => RescueUnsavedEditsService.clear());

export default router;
