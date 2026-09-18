const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function openMembers(page) {
  page.loadPath('setup_manual_oatmilk_invitations');
  page.expectText('.group-page__name', 'Oatmilk Cooperative');
  page.pause(1000);
  page.click('.group-page-members-tab');
  page.waitFor('.members-panel');
}

function openInvitations(page) {
  openMembers(page);
  page.click('.members-panel__filters');
  page.waitFor('.v-overlay .members-panel__filters-invitations');
  page.click('.v-overlay .members-panel__filters-invitations');
  page.waitFor('.membership-dropdown__button');
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'member_invite_actions': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openMembers(page);
    page.expectText('.membership-card__invite', 'Invite');
    page.expectText('.members-panel__shareable-link-btn', 'Shareable Link');
    screenshot.capture('groups/inviting_people/group_join_group_invite', {
      spotlight: {
        selectors: ['.membership-card__invite', '.members-panel__shareable-link-btn'],
        padding: 14,
        radius: 14,
        opacity: 0.4,
        outlineWidth: 0
      }
    });
  },

  'invite_by_email': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openMembers(page);
    page.click('.membership-card__invite');
    page.waitFor('.group-invitation-form');
    page.expectText('.group-invitation-form', 'Invite people to Oatmilk Cooperative');
    screenshot.captureElement('groups/inviting_people/group_invite_email', '.group-invitation-form', {height: 1000});
  },

  'invite_to_subgroups': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_subgroup_invitations');
    page.expectText('.group-page__name', 'Packaging Working Group');
    page.pause(1000);
    page.execute("Array.from(document.querySelectorAll('.sidebar__groups a')).find(el => el.offsetParent && el.textContent.includes('Oatmilk Cooperative')).click()");
    page.expectText('.group-page__name', 'Oatmilk Cooperative');
    page.click('.group-page-members-tab');
    page.waitFor('.members-panel');
    page.click('.membership-card__invite');
    page.waitFor('.group-invitation-form');
    page.expectText('.group-invitation-form', 'Packaging Working Group');
    page.execute("document.querySelectorAll('.invitation-form__select-groups input')[1].click()");
    page.pause(200);
    screenshot.captureElement('groups/inviting_people/group_invite_email_subgroups', '.group-invitation-form', {height: 1000});
  },

  'shareable_link': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openMembers(page);
    page.click('.members-panel__shareable-link-btn');
    page.waitFor('.shareable-link-modal');
    test.expect.element('.shareable-link-modal__shareable-link input').value.to.contain('/join/');
    page.execute("const input = document.querySelector('.shareable-link-modal__shareable-link input'); input.value = 'https://www.loomio.com/join/group/oatmilk-example/'; input.setAttribute('value', input.value)");
    screenshot.captureElement('groups/inviting_people/group_invite_sharable_link', '.shareable-link-modal', {height: 800});
  },

  'request_to_join': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_join_group');
    page.expectText('.group-page__name', 'Oatmilk Cooperative');
    page.expectText('.join-group-button', 'Join group');
    screenshot.capture('groups/inviting_people/group_join_group', {
      spotlight: {
        selector: '.join-group-button',
        padding: 14,
        radius: 14,
        opacity: 0.4,
        outlineWidth: 0
      }
    });
  },

  'request_to_join_form': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_join_group');
    page.expectText('.group-page__name', 'Oatmilk Cooperative');
    page.click('.join-group-button');
    page.waitFor('.membership-request-form');
    page.fillIn(
      '.membership-request-form__introduction textarea',
      'I coordinate deliveries for a local cafe and would like to help with the returnable bottle trial.'
    );
    screenshot.captureElement(
      'groups/inviting_people/group_request_to_join',
      '.membership-request-form',
      {height: 900}
    );
  },

  'review_request_to_join': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_membership_request');
    page.waitFor('.requests-panel');
    page.expectText('.membership-request__name', 'Riley Thompson');
    screenshot.captureElement(
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
  },

  'decline_request_to_join': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_membership_request');
    page.waitFor('.membership-requests-page__decline');
    page.click('.membership-requests-page__decline');
    page.waitFor('.membership-request__decline-reason-input');
    page.fillIn(
      '.membership-request__decline-reason-input textarea',
      'Please tell us which cafe you work with and how you would like to contribute.'
    );
    screenshot.captureElement(
      'groups/inviting_people/group_decline_request_to_join',
      '.v-overlay .v-card',
      {height: 900}
    );
  },

  'invitation_filter': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openMembers(page);
    page.resizeWindow(1280, 900);
    page.pause(300);
    page.click('.members-panel__filters');
    page.waitFor('.v-overlay .members-panel__filters-invitations');
    screenshot.capture('groups/inviting_people/group_invite_members_filter', {
      spotlight: {
        selector: '.v-overlay .members-panel__filters-invitations',
        padding: 14,
        radius: 14,
        opacity: 0.4,
        outlineWidth: 0
      }
    });
  },

  'resend_invitation': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openInvitations(page);
    page.click('.membership-dropdown__button');
    page.waitFor('.v-overlay .membership-dropdown__resend');
    screenshot.capture('groups/inviting_people/group_invite_resend_invitation', {
      spotlight: {
        selector: '.v-overlay .membership-dropdown__resend',
        padding: 14,
        radius: 14,
        opacity: 0.4,
        outlineWidth: 0
      }
    });
  },

  'cancel_invitation': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openInvitations(page);
    page.click('.membership-dropdown__button');
    page.waitFor('.v-overlay .membership-dropdown__remove');
    screenshot.capture('groups/inviting_people/group_invite_cancel_invitation', {
      spotlight: {
        selector: '.v-overlay .membership-dropdown__remove',
        padding: 14,
        radius: 14,
        opacity: 0.4,
        outlineWidth: 0
      }
    });
  }
};
