import { mount, flushPromises } from '@vue/test-utils';
import { beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({getMember: vi.fn()}));
vi.mock('@/shared/services/records', () => ({default: {memberships: {remote: {getMember: mocks.getMember}}}}));
vi.mock('vue-i18n', () => ({useI18n: () => ({t: key => key})}));
vi.mock('@/components/common/time_ago.vue', () => ({default: {template: '<span />'}}));
vi.mock('@/components/common/dismiss_modal_button.vue', () => ({default: {template: '<span />'}}));
import NotificationHistory from '@/components/group/notification_history.vue';

const membership = {id: 14, user: () => ({nameOrUsername: () => 'Member'})};
const entry = id => ({
  id, kind: 'membership_created', created_at: '2026-10-21T01:00:00Z', sender_name: 'Coordinator',
  message: 'Please join our forum', email_subject: 'An invitation', email_status: 'sent',
  email_sent_at: '2026-10-21T01:00:01Z', email_events: []
});
const mountHistory = () => mount(NotificationHistory, {props: {membership}, global: {stubs: {
  VCard: {template: '<section><slot name="append"/><slot/></section>'},
  VCardText: {template: '<div><slot/></div>'},
  VBtn: {props: ['disabled'], template: '<button :disabled="disabled"><slot/></button>'},
  DismissModalButton: true, TimeAgo: true
}}});

describe('membership notification history', () => {
  beforeEach(() => mocks.getMember.mockReset());

  it('shows custom messages resends and reported email feedback without treating sends as inbox delivery', async () => {
    const invitation = entry(1);
    invitation.email_events = [
      {id: 8, kind: 'sent', occurred_at: invitation.email_sent_at},
      {id: 9, kind: 'bounced', occurred_at: invitation.created_at, detail: '550 Unknown mailbox'}
    ];
    const resend = {...entry(2), kind: 'membership_resent', message: null, email_status: 'pending', email_sent_at: null};
    mocks.getMember.mockResolvedValue({history: [resend, invitation]});
    const wrapper = mountHistory();
    await flushPromises();

    expect(mocks.getMember).toHaveBeenCalledWith(14, 'notification_history', {limit: 20, offset: 0});
    expect(wrapper.text()).toContain('Please join our forum');
    expect(wrapper.text()).toContain('membership_notification_history.no_custom_message');
    expect(wrapper.text()).toContain('membership_notification_history.sent');
    expect(wrapper.text()).toContain('membership_notification_history.bounced');
    expect(wrapper.text()).toContain('550 Unknown mailbox');
    expect(wrapper.text()).not.toContain('membership_notification_history.delivered');
  });

  it('renders message and provider diagnostic content as text', async () => {
    const invitation = {...entry(1), message: '<img src=x onerror=alert(1)>'};
    invitation.email_events = [{id: 1, kind: 'bounced', occurred_at: invitation.created_at, detail: '<script>alert(1)</script>'}];
    mocks.getMember.mockResolvedValue({history: [invitation]});
    const wrapper = mountHistory();
    await flushPromises();
    expect(wrapper.find('img').exists()).toBe(false);
    expect(wrapper.find('script').exists()).toBe(false);
    expect(wrapper.text()).toContain(invitation.message);
  });

  it('loads more history using offset and retries failures without losing existing rows', async () => {
    mocks.getMember.mockResolvedValueOnce({history: Array.from({length: 20}, (_, i) => entry(i))})
      .mockRejectedValueOnce(new Error('unavailable')).mockResolvedValueOnce({history: [entry(20)]});
    const wrapper = mountHistory();
    await flushPromises();
    await wrapper.get('button').trigger('click');
    await flushPromises();
    expect(wrapper.get('[role="alert"]').exists()).toBe(true);
    expect(wrapper.findAll('article')).toHaveLength(20);
    await wrapper.get('button').trigger('click');
    await flushPromises();
    expect(mocks.getMember).toHaveBeenLastCalledWith(14, 'notification_history', {limit: 20, offset: 20});
    expect(wrapper.findAll('article')).toHaveLength(21);
  });

  it('explains an empty history after loading', async () => {
    mocks.getMember.mockResolvedValue({history: []});
    const wrapper = mountHistory();
    await flushPromises();
    expect(wrapper.text()).toContain('membership_notification_history.no_invitations_recorded');
  });
});
