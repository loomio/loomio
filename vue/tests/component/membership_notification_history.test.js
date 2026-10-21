import { mount, flushPromises } from '@vue/test-utils';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { createVuetify } from 'vuetify';

const mocks = vi.hoisted(() => ({getMember: vi.fn()}));
vi.mock('@/shared/services/records', () => ({default: {memberships: {remote: {getMember: mocks.getMember}}}}));
vi.mock('vue-i18n', () => ({useI18n: () => ({t: key => key})}));
vi.mock('@/components/common/time_ago.vue', () => ({default: {template: '<span />'}}));
vi.mock('@/components/common/dismiss_modal_button.vue', () => ({default: {template: '<span />'}}));
vi.mock('@/components/common/icon.vue', () => ({default: {template: '<span />'}}));
import NotificationHistory from '@/components/group/notification_history.vue';

const membership = {id: 14, userEmail: 'member@example.com', user: () => ({nameOrUsername: () => 'Member'})};
const entry = id => ({
  id, kind: 'membership_created', created_at: '2026-10-21T01:00:00Z', sender_name: 'Coordinator',
  message: 'Please join our forum', email_subject: 'An invitation', email_status: 'sent',
  email_sent_at: '2026-10-21T01:00:01Z', email_events: []
});
let mountedHistory;
const mountHistory = () => (mountedHistory = mount(NotificationHistory, {props: {membership}, global: {plugins: [createVuetify()], stubs: {
  VCard: {template: '<section><slot name="append"/><slot/></section>'},
  VCardText: {template: '<div><slot/></div>'},
  VBtn: {props: ['disabled'], template: '<button :disabled="disabled"><slot/></button>'},
  VChip: {template: '<span><slot/></span>'},
  CommonIcon: true, DismissModalButton: true, TimeAgo: true
}}}));

describe('membership notification history', () => {
  beforeEach(() => {
    mocks.getMember.mockReset();
    vi.stubGlobal('ResizeObserver', class { observe() {} unobserve() {} disconnect() {} });
    vi.stubGlobal('matchMedia', () => ({matches: false, addEventListener() {}, removeEventListener() {}}));
  });
  afterEach(() => {
    mountedHistory?.unmount();
    vi.unstubAllGlobals();
  });

  it('keeps messages and delivery diagnostics inside collapsed invitation rows', async () => {
    const invitation = {...entry(1), email_status: 'bounced'};
    invitation.email_events = [
      {id: 8, kind: 'sent', occurred_at: invitation.email_sent_at},
      {id: 9, kind: 'bounced', occurred_at: '2026-10-21T01:01:00Z', detail: '550 Unknown mailbox'}
    ];
    const resend = {...entry(2), kind: 'membership_resent', message: null, email_status: 'pending', email_sent_at: null};
    mocks.getMember.mockResolvedValue({email_delivery_blocked: false, history: [resend, invitation]});
    const wrapper = mountHistory();
    await flushPromises();

    expect(mocks.getMember).toHaveBeenCalledWith(14, 'notification_history', {limit: 20, offset: 0});
    expect(wrapper.attributes('subtitle')).toBe('Member <member@example.com>');
    const row = wrapper.findAll('.v-expansion-panel')[1];
    const title = row.get('.v-expansion-panel-title');
    expect(title.attributes('aria-expanded')).toBe('false');
    expect(title.text()).toContain('membership_notification_history.delivery_result.failed');
    expect(row.find('.membership-notification-history__message').exists()).toBe(false);
    expect(title.text()).not.toContain(invitation.email_subject);
    expect(title.text()).not.toContain('550 Unknown mailbox');
    expect(wrapper.find('.membership-notification-history__blocked').exists()).toBe(false);

    await title.trigger('click');
    await flushPromises();
    expect(title.attributes('aria-expanded')).toBe('true');
    expect(row.get('.membership-notification-history__details').text()).toContain(invitation.message);
    expect(row.get('.membership-notification-history__details').text()).toContain('550 Unknown mailbox');
    expect(row.get('.membership-notification-history__status').text()).toContain('membership_notification_history.bounced');
    expect(row.find('ul').exists()).toBe(false);
  });

  it('shows completed sends as delivered while retaining the precise evidence in the expanded status', async () => {
    const sent = entry(1);
    const delivered = {...entry(2), email_status: 'delivered', email_events: [
      {id: 3, kind: 'delivered', occurred_at: '2026-10-21T01:02:00Z'}
    ]};
    mocks.getMember.mockResolvedValue({email_delivery_blocked: false, history: [sent, delivered]});
    const wrapper = mountHistory();
    await flushPromises();

    expect(wrapper.findAll('[data-result="delivered"]')).toHaveLength(2);
    const rows = wrapper.findAll('.v-expansion-panel');
    expect(rows[0].get('.v-expansion-panel-title').text()).not.toContain('membership_notification_history.sent');
    await rows[0].get('.v-expansion-panel-title').trigger('click');
    await flushPromises();
    expect(rows[0].get('.membership-notification-history__status').text()).toContain('membership_notification_history.sent');
    await rows[1].get('.v-expansion-panel-title').trigger('click');
    await flushPromises();
    expect(rows[1].get('.membership-notification-history__status').text()).toContain('membership_notification_history.delivered');
    expect(rows[0].get('.v-expansion-panel-title').attributes('aria-expanded')).toBe('false');
  });

  it('replaces a successful result with the latest complaint rather than displaying an earlier success', async () => {
    const invitation = {...entry(1), email_status: 'complained', email_events: [
      {id: 1, kind: 'delivered', occurred_at: '2026-10-21T01:02:00Z'},
      {id: 2, kind: 'complained', occurred_at: '2026-10-21T01:03:00Z', detail: 'Reported as spam'}
    ]};
    mocks.getMember.mockResolvedValue({email_delivery_blocked: false, history: [invitation]});
    const wrapper = mountHistory();
    await flushPromises();

    expect(wrapper.find('[data-result="delivered"]').exists()).toBe(false);
    expect(wrapper.find('[data-result="failed"]').exists()).toBe(true);
    await wrapper.get('.v-expansion-panel-title').trigger('click');
    await flushPromises();
    expect(wrapper.get('.membership-notification-history__status').text()).toContain('membership_notification_history.complained');
    expect(wrapper.get('.membership-notification-history__diagnostic').text()).toBe('Reported as spam');
  });

  it('does not label pending, delayed or unknown historical sends as failures', async () => {
    mocks.getMember.mockResolvedValue({email_delivery_blocked: false, history: ['pending', 'delayed', 'not_sent'].map((status, id) => ({
      ...entry(id), email_status: status
    }))});
    const wrapper = mountHistory();
    await flushPromises();

    expect(wrapper.find('[data-result]').exists()).toBe(false);
    const rows = wrapper.findAll('.v-expansion-panel-title');
    expect(rows[0].text()).toContain('membership_notification_history.pending');
    expect(rows[1].text()).toContain('membership_notification_history.delayed');
    expect(rows[2].text()).toContain('membership_notification_history.not_sent');
  });

  it('renders message and provider diagnostic content as text', async () => {
    const invitation = {...entry(1), email_status: 'bounced', message: '<img src=x onerror=alert(1)>'};
    invitation.email_events = [{id: 1, kind: 'bounced', occurred_at: invitation.created_at, detail: '<script>alert(1)</script>'}];
    mocks.getMember.mockResolvedValue({email_delivery_blocked: false, history: [invitation]});
    const wrapper = mountHistory();
    await flushPromises();
    await wrapper.get('.v-expansion-panel-title').trigger('click');
    await flushPromises();
    expect(wrapper.find('img').exists()).toBe(false);
    expect(wrapper.find('script').exists()).toBe(false);
    expect(wrapper.get('.membership-notification-history__message code').text()).toBe(invitation.message);
    expect(wrapper.get('.membership-notification-history__diagnostic').text()).toBe('<script>alert(1)</script>');
  });

  it('loads more history using offset and retries failures without losing existing rows', async () => {
    mocks.getMember.mockResolvedValueOnce({email_delivery_blocked: true, history: Array.from({length: 20}, (_, i) => entry(i))})
      .mockRejectedValueOnce(new Error('unavailable')).mockResolvedValueOnce({email_delivery_blocked: false, history: [entry(20)]});
    const wrapper = mountHistory();
    await flushPromises();
    await wrapper.get('.membership-notification-history__more').trigger('click');
    await flushPromises();
    expect(wrapper.get('[role="alert"]').exists()).toBe(true);
    expect(wrapper.findAll('.v-expansion-panel')).toHaveLength(20);
    await wrapper.get('.membership-notification-history__more').trigger('click');
    await flushPromises();
    expect(mocks.getMember).toHaveBeenLastCalledWith(14, 'notification_history', {limit: 20, offset: 20});
    expect(wrapper.findAll('.v-expansion-panel')).toHaveLength(21);
    expect(wrapper.find('.membership-notification-history__blocked').exists()).toBe(false);
  });

  it('shows the current address block above the history even when there are no invitations', async () => {
    mocks.getMember.mockResolvedValue({email_delivery_blocked: true, history: []});
    const wrapper = mountHistory();
    await flushPromises();

    const warning = wrapper.get('.membership-notification-history__blocked');
    expect(warning.text()).toContain('membership_notification_history.email_delivery_blocked');
    expect(wrapper.text().indexOf(warning.text())).toBeLessThan(wrapper.text().indexOf('membership_notification_history.no_invitations_recorded'));
  });

  it('explains an empty history after loading', async () => {
    mocks.getMember.mockResolvedValue({email_delivery_blocked: false, history: []});
    const wrapper = mountHistory();
    await flushPromises();
    expect(wrapper.text()).toContain('membership_notification_history.no_invitations_recorded');
  });
});
