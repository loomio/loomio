import { shallowMount } from '@vue/test-utils';
import { createI18n } from 'vue-i18n';
import { beforeEach, describe, expect, it, vi } from 'vitest';

const config = vi.hoisted(() => ({
  baseUrl: 'https://private.example.org',
  userManual: {},
  features: {app: {help_link: true}}
}));

vi.mock('@/shared/services/app_config', () => ({default: config}));
vi.mock('@/shared/services/session', () => ({default: {}}));
vi.mock('@/shared/services/flash', () => ({default: {}}));
vi.mock('@/shared/services/records', () => ({default: {}}));
vi.mock('@/shared/services/plausible_service', () => ({default: {}}));
vi.mock('@/shared/services/lmo_url_service', () => ({default: {}}));
vi.mock('vue-router', () => ({useRouter: () => ({}), useRoute: () => ({})}));

import HelpLink from '@/components/common/help_link.vue';
import HelpButton from '@/components/common/help_btn.vue';
import SidebarHelp from '@/components/sidebar/help.vue';
import { manualUrl } from '@/shared/helpers/manual_url';

function mountHelp(component, locale, props = {}) {
  const i18n = createI18n({
    legacy: false, locale, fallbackLocale: 'en',
    messages: {en: {}}, missingWarn: false, fallbackWarn: false
  });
  const wrapper = shallowMount(component, {
    props,
    global: {plugins: [i18n], stubs: {VList: {template: '<div><slot /></div>'}}}
  });
  return {wrapper, i18n};
}

describe('manual URLs', () => {
  it.each([['fr', 'fr'], ['pt_BR', 'pt-br'], ['nl_NL', 'nl']])('maps app locale %s to docs directory %s', (appLocale, directory) => {
    expect(manualUrl('user_manual/groups/settings', appLocale))
      .toBe(`https://www.loomio.com/docs/${directory}/user_manual/groups/settings`);
  });

  it('falls back to English for an unsupported app locale', () => {
    expect(manualUrl('en/user_manual/groups/settings', 'ar'))
      .toBe('https://www.loomio.com/docs/en/user_manual/groups/settings');
  });

  it('preserves section anchors and localizes guides', () => {
    expect(manualUrl('en/guides/making_decisions/consent_process#reaction-round', 'fr'))
      .toBe('https://www.loomio.com/docs/fr/guides/making_decisions/consent_process#reaction-round');
  });

  it('keeps policies and the changelog in English', () => {
    expect(manualUrl('policy/privacy', 'fr')).toBe('https://www.loomio.com/docs/en/policy/privacy');
    expect(manualUrl('user_manual/changelog', 'fr')).toBe('https://www.loomio.com/docs/en/user_manual/changelog');
  });
});

describe('help entry points', () => {
  beforeEach(() => { config.userManual = {}; });

  it.each([HelpLink, HelpButton])('updates its URL when the active app language changes', async component => {
    const {wrapper, i18n} = mountHelp(component, 'fr', {path: 'en/user_manual/groups/settings'});
    expect(wrapper.find('.help-link').attributes('href'))
      .toBe('https://www.loomio.com/docs/fr/user_manual/groups/settings');
    i18n.global.locale.value = 'de';
    await wrapper.vm.$nextTick();
    expect(wrapper.find('.help-link').attributes('href'))
      .toBe('https://www.loomio.com/docs/de/user_manual/groups/settings');
  });

  it('opens the translated manual from the sidebar and retains the source host', () => {
    const {wrapper} = mountHelp(SidebarHelp, 'he');
    expect(wrapper.find('[href]').attributes('href'))
      .toBe('https://www.loomio.com/docs/he/user_manual/overview?utm_source=private.example.org');
  });

  it('preserves a host-specific manual URL', () => {
    config.userManual = {url: 'https://private.example.org/handbook'};
    const {wrapper} = mountHelp(SidebarHelp, 'fr');
    expect(wrapper.find('[href]').attributes('href')).toBe(config.userManual.url);
  });
});
