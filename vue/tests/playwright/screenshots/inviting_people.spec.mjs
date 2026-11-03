import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

async function openMembers(page) {
  await page.goto('/dev/setup_manual_oatmilk_invitations')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await page.locator('.group-page-members-tab').click()
  await expect(page.locator('.members-panel').first()).toBeVisible()
}

async function openInvitations(page) {
  await openMembers(page);
  await page.locator('.members-panel__filters').click()
  await page.locator('.v-overlay .members-panel__filters-invitations').click()
  await expect(page.locator('.membership-dropdown__button').first()).toBeVisible()
}

test('member_invite_actions', async ({ page, manual: screenshot }) => {
  await openMembers(page);
  await expectLabel(page.locator('.membership-card__invite'), 'Invite')
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

test('invite_by_email', async ({ page, manual: screenshot }) => {
  await openMembers(page);
  await page.locator('.membership-card__invite').click()
  await expect(page.locator('.group-invitation-form').first()).toBeVisible()
  await expectLabel(page.locator('.group-invitation-form'), 'Invite people to Oatmilk Cooperative')
  await screenshot.captureElement('groups/inviting_people/group_invite_email', '.group-invitation-form', {height: 1000});
});

test('invite_to_subgroups', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_subgroup_invitations')
  await expectLabel(page.locator('.group-page__name'), 'Packaging Working Group')
  await page.evaluate("Array.from(document.querySelectorAll('.sidebar__groups a')).find(el => el.offsetParent && el.textContent.includes('Oatmilk Cooperative')).click()")
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await page.locator('.group-page-members-tab').click()
  await expect(page.locator('.members-panel').first()).toBeVisible()
  await page.locator('.membership-card__invite').click()
  await expect(page.locator('.group-invitation-form').first()).toBeVisible()
  await expectLabel(page.locator('.group-invitation-form'), 'Packaging Working Group')
  await page.evaluate("document.querySelectorAll('.invitation-form__select-groups input')[1].click()")
  await screenshot.captureElement('groups/inviting_people/group_invite_email_subgroups', '.group-invitation-form', {height: 1000});
});

test('shareable_link', async ({ page, manual: screenshot }) => {
  await openMembers(page);
  await page.locator('.membership-card__invite').click()
  await expect(page.locator('.group-invitation-form').first()).toBeVisible()
  await page.locator('.group-invitation-form a').click()
  await expect(page.locator('.shareable-link-modal').first()).toBeVisible()
  await expect(page.locator('.shareable-link-modal__shareable-link input')).toHaveValue('/join/')
  await page.evaluate("const input = document.querySelector('.shareable-link-modal__shareable-link input'); input.value = 'https://www.loomio.com/join/group/oatmilk-example/'; input.setAttribute('value', input.value)")
  await screenshot.captureElement('groups/inviting_people/group_invite_sharable_link', '.shareable-link-modal', {height: 800});
});

test('request_to_join', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_join_group')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await expectLabel(page.locator('.join-group-button'), 'Join group')
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

test('request_to_join_form', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_join_group')
  await expectLabel(page.locator('.group-page__name'), 'Oatmilk Cooperative')
  await page.locator('.join-group-button').click()
  await expect(page.locator('.membership-request-form').first()).toBeVisible()
  await page.locator('.membership-request-form__introduction textarea').fill('I coordinate deliveries for a local cafe and would like to help with the returnable bottle trial.')
  await screenshot.captureElement(
    'groups/inviting_people/group_request_to_join',
    '.membership-request-form',
    {height: 900}
  );
});

test('review_request_to_join', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_membership_request')
  await expect(page.locator('.requests-panel').first()).toBeVisible()
  await expectLabel(page.locator('.membership-request__name'), 'Riley Thompson')
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
  await page.goto('/dev/setup_manual_oatmilk_membership_request')
  await page.locator('.membership-requests-page__decline').click()
  await expect(page.locator('.membership-request__decline-reason-input').first()).toBeVisible()
  await page.locator('.membership-request__decline-reason-input textarea').fill('Please tell us which cafe you work with and how you would like to contribute.')
  await screenshot.captureElement(
    'groups/inviting_people/group_decline_request_to_join',
    '.v-overlay .v-card',
    {height: 900}
  );
});

test('invitation_filter', async ({ page, manual: screenshot }) => {
  await openMembers(page);
  await page.setViewportSize({ width: 1280, height: 900 })
  await page.locator('.members-panel__filters').click()
  await expect(page.locator('.v-overlay .members-panel__filters-invitations').first()).toBeVisible()
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

test('resend_invitation', async ({ page, manual: screenshot }) => {
  await openInvitations(page);
  await page.locator('.membership-dropdown__button').click()
  await expect(page.locator('.v-overlay .membership-dropdown__resend').first()).toBeVisible()
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

test('cancel_invitation', async ({ page, manual: screenshot }) => {
  await openInvitations(page);
  await page.locator('.membership-dropdown__button').click()
  await expect(page.locator('.v-overlay .membership-dropdown__remove').first()).toBeVisible()
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
