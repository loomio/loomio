import { test, expect } from '../screenshotFixtures.mjs';

async function openMembers(page) {
  await page.loadPath('setup_manual_oatmilk_invitations');
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.pause(1000);
  await page.click('.group-page-members-tab');
  await page.waitFor('.members-panel');
}

async function openInvitations(page) {
  await openMembers(page);
  await page.click('.members-panel__filters');
  await page.waitFor('.v-overlay .members-panel__filters-invitations');
  await page.click('.v-overlay .members-panel__filters-invitations');
  await page.waitFor('.membership-dropdown__button');
}

test('member_invite_actions', async ({ lmo: page, manual: screenshot }) => {
  await openMembers(page);
  await page.expectText('.membership-card__invite', 'Invite');
  await screenshot.capture('groups/inviting_people/group_join_group_invite', {
    spotlight: {
      selector: '.membership-card__invite',
      padding: 14,
      radius: 14,
      opacity: 0.4,
      outlineWidth: 0
    }
  });
});

test('invite_by_email', async ({ lmo: page, manual: screenshot }) => {
  await openMembers(page);
  await page.click('.membership-card__invite');
  await page.waitFor('.group-invitation-form');
  await page.expectText('.group-invitation-form', 'Invite people to Oatmilk Cooperative');
  await screenshot.captureElement('groups/inviting_people/group_invite_email', '.group-invitation-form', {height: 1000});
});

test('invite_to_subgroups', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_subgroup_invitations');
  await page.expectText('.group-page__name', 'Packaging Working Group');
  await page.pause(1000);
  await page.execute("Array.from(document.querySelectorAll('.sidebar__groups a')).find(el => el.offsetParent && el.textContent.includes('Oatmilk Cooperative')).click()");
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.click('.group-page-members-tab');
  await page.waitFor('.members-panel');
  await page.click('.membership-card__invite');
  await page.waitFor('.group-invitation-form');
  await page.expectText('.group-invitation-form', 'Packaging Working Group');
  await page.execute("document.querySelectorAll('.invitation-form__select-groups input')[1].click()");
  await page.pause(200);
  await screenshot.captureElement('groups/inviting_people/group_invite_email_subgroups', '.group-invitation-form', {height: 1000});
});

test('shareable_link', async ({ lmo: page, manual: screenshot }) => {
  await openMembers(page);
  await page.click('.membership-card__invite');
  await page.waitFor('.group-invitation-form');
  await page.click('.group-invitation-form a');
  await page.waitFor('.shareable-link-modal');
  await page.expectValue('.shareable-link-modal__shareable-link input', '/join/');
  await page.execute("const input = document.querySelector('.shareable-link-modal__shareable-link input'); input.value = 'https://www.loomio.com/join/group/oatmilk-example/'; input.setAttribute('value', input.value)");
  await screenshot.captureElement('groups/inviting_people/group_invite_sharable_link', '.shareable-link-modal', {height: 800});
});

test('request_to_join', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_join_group');
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.expectText('.join-group-button', 'Join group');
  await screenshot.capture('groups/inviting_people/group_join_group', {
    spotlight: {
      selector: '.join-group-button',
      padding: 14,
      radius: 14,
      opacity: 0.4,
      outlineWidth: 0
    }
  });
});

test('request_to_join_form', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_join_group');
  await page.expectText('.group-page__name', 'Oatmilk Cooperative');
  await page.click('.join-group-button');
  await page.waitFor('.membership-request-form');
  await page.fillIn(
    '.membership-request-form__introduction textarea',
    'I coordinate deliveries for a local cafe and would like to help with the returnable bottle trial.'
  );
  await screenshot.captureElement(
    'groups/inviting_people/group_request_to_join',
    '.membership-request-form',
    {height: 900}
  );
});

test('review_request_to_join', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_membership_request');
  await page.waitFor('.requests-panel');
  await page.expectText('.membership-request__name', 'Riley Thompson');
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

test('decline_request_to_join', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_membership_request');
  await page.waitFor('.membership-requests-page__decline');
  await page.click('.membership-requests-page__decline');
  await page.waitFor('.membership-request__decline-reason-input');
  await page.fillIn(
    '.membership-request__decline-reason-input textarea',
    'Please tell us which cafe you work with and how you would like to contribute.'
  );
  await screenshot.captureElement(
    'groups/inviting_people/group_decline_request_to_join',
    '.v-overlay .v-card',
    {height: 900}
  );
});

test('invitation_filter', async ({ lmo: page, manual: screenshot }) => {
  await openMembers(page);
  await page.resizeWindow(1280, 900);
  await page.pause(300);
  await page.click('.members-panel__filters');
  await page.waitFor('.v-overlay .members-panel__filters-invitations');
  await screenshot.capture('groups/inviting_people/group_invite_members_filter', {
    spotlight: {
      selector: '.v-overlay .members-panel__filters-invitations',
      padding: 14,
      radius: 14,
      opacity: 0.4,
      outlineWidth: 0
    }
  });
});

test('resend_invitation', async ({ lmo: page, manual: screenshot }) => {
  await openInvitations(page);
  await page.click('.membership-dropdown__button');
  await page.waitFor('.v-overlay .membership-dropdown__resend');
  await screenshot.capture('groups/inviting_people/group_invite_resend_invitation', {
    spotlight: {
      selector: '.v-overlay .membership-dropdown__resend',
      padding: 14,
      radius: 14,
      opacity: 0.4,
      outlineWidth: 0
    }
  });
});

test('cancel_invitation', async ({ lmo: page, manual: screenshot }) => {
  await openInvitations(page);
  await page.click('.membership-dropdown__button');
  await page.waitFor('.v-overlay .membership-dropdown__remove');
  await screenshot.capture('groups/inviting_people/group_invite_cancel_invitation', {
    spotlight: {
      selector: '.v-overlay .membership-dropdown__remove',
      padding: 14,
      radius: 14,
      opacity: 0.4,
      outlineWidth: 0
    }
  });
});
