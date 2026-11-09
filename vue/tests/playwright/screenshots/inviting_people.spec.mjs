import { test, expect, expectLabel } from '../screenshotFixtures.mjs';
import { openMembers as openMembersTab } from '../helpers/members.mjs';
import { sidebarGroup } from '../helpers/groups.mjs';

const menuSpotlight = selector => ({ selector, padding: 14, radius: 14, opacity: 0.4, outlineWidth: 0 });
const invitationForm = page => page.locator('.group-invitation-form');

async function openMembers(page) {
  await page.goto('/dev/setup_manual_oatmilk_invitations');
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative');
  await openMembersTab(page);
  await expect(page.locator('.members-panel')).toBeVisible();
}

async function openInvitations(page) {
  await openMembers(page);
  await page.locator('.members-panel__filters').click();
  await page.locator('.v-overlay--active .members-panel__filters-invitations').click();
  // Open the first invitation's menu; any invitation will do.
  await page.locator('.membership-dropdown__button').first().click();
}

async function openInviteForm(page) {
  await page.locator('.membership-card__invite').click();
  await expect(invitationForm(page)).toBeVisible();
}

test('member_invite_actions', async ({ page, manual: screenshot }) => {
  await openMembers(page);
  await expectLabel(page.locator('.membership-card__invite'), 'Invite');
  await screenshot.capture('groups/inviting_people/group_join_group_invite', {
    spotlight: menuSpotlight('.membership-card__invite')
  });
});

test('invite_by_email', async ({ page, manual: screenshot }) => {
  await openMembers(page);
  await openInviteForm(page);
  await expectLabel(invitationForm(page), 'Invite people to Oatmilk Cooperative');
  await screenshot.captureElement('groups/inviting_people/group_invite_email', '.group-invitation-form', { height: 1000 });
});

test('invite_to_subgroups', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_subgroup_invitations');
  await expectLabel(page.locator('.group-page__name'), 'Packaging Working Group');
  // Follow the sidebar link without opening the sidebar, which would change the page.
  await sidebarGroup(page, 'Oatmilk Cooperative').dispatchEvent('click');
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative');
  await openMembersTab(page);
  await openInviteForm(page);
  await expectLabel(invitationForm(page), 'Packaging Working Group');
  await invitationForm(page).locator('.invitation-form__select-groups', { hasText: 'Packaging Working Group' }).locator('input').check();
  await screenshot.captureElement('groups/inviting_people/group_invite_email_subgroups', '.group-invitation-form', { height: 1000 });
});

test('shareable_link', async ({ page, manual: screenshot }) => {
  await openMembers(page);
  await openInviteForm(page);
  await page.locator('.invitation-form__shareable-link').click();
  const link = page.locator('.shareable-link-modal__shareable-link input');
  await expect(link).toHaveValue(/\/join\//);
  // Show a production address rather than the test server's.
  await link.evaluate(input => {
    input.value = 'https://www.loomio.com/join/group/oatmilk-example/';
    input.setAttribute('value', input.value);
  });
  await screenshot.captureElement('groups/inviting_people/group_invite_sharable_link', '.shareable-link-modal', { height: 800 });
});

test('request_to_join', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_join_group');
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative');
  await expectLabel(page.locator('.join-group-button'), 'Join group');
  await screenshot.capture('groups/inviting_people/group_join_group', {
    spotlight: menuSpotlight('.join-group-button')
  });
});

test('request_to_join_form', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_join_group');
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative');
  await page.locator('.join-group-button').click();
  await page.locator('.membership-request-form__introduction textarea').fill('I coordinate deliveries for a local cafe and would like to help with the returnable bottle trial.');
  await screenshot.captureElement(
    'groups/inviting_people/group_request_to_join',
    '.membership-request-form',
    { height: 900 }
  );
});

test('review_request_to_join', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_membership_request');
  await expectLabel(page.locator('.requests-panel .membership-request__name'), 'Riley Thompson');
  await screenshot.captureElement(
    'groups/inviting_people/group_review_request_to_join',
    '.requests-panel',
    {
      height: 900,
      spotlight: {
        selectors: ['.membership-requests-page__approve', '.membership-requests-page__decline'],
        padding: 12,
        radius: 14,
        opacity: 0.4,
        outlineWidth: 0
      }
    }
  );
});

test('decline_request_to_join', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_membership_request');
  await page.locator('.membership-requests-page__decline').click();
  await page.locator('.membership-request__decline-reason-input textarea').fill('Please tell us which cafe you work with and how you would like to contribute.');
  await screenshot.captureElement(
    'groups/inviting_people/group_decline_request_to_join',
    '.membership-request__decline-dialog',
    { height: 900 }
  );
});

test('invitation_filter', async ({ page, manual: screenshot }) => {
  await openMembers(page);
  await page.setViewportSize({ width: 1280, height: 900 });
  await page.locator('.members-panel__filters').click();
  await expect(page.locator('.v-overlay--active .members-panel__filters-invitations')).toBeVisible();
  await screenshot.capture('groups/inviting_people/group_invite_members_filter', {
    spotlight: menuSpotlight('.v-overlay .members-panel__filters-invitations')
  });
});

for (const [name, action] of [['resend_invitation', 'resend'], ['cancel_invitation', 'remove']]) {
  test(name, async ({ page, manual: screenshot }) => {
    await openInvitations(page);
    await expect(page.locator(`.v-overlay--active .membership-dropdown__${action}`)).toBeVisible();
    await screenshot.capture(`groups/inviting_people/group_invite_${name}`, {
      spotlight: menuSpotlight(`.v-overlay .membership-dropdown__${action}`)
    });
  });
}
