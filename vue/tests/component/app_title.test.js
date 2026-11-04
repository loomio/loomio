import { createI18n } from 'vue-i18n';
import { beforeEach, describe, expect, it, vi } from 'vitest';

vi.mock('@/shared/services/app_config', () => ({default: {theme: {site_name: 'Loomio'}}}));
vi.mock('@/shared/services/ability_service', () => ({default: {}}));
vi.mock('@/shared/services/session', () => ({default: {}}));
vi.mock('@/shared/services/flash', () => ({default: {}}));
vi.mock('@/shared/helpers/message_bus', () => ({initLiveUpdate: vi.fn(), closeLiveUpdate: vi.fn()}));
vi.mock('@/components/sidebar/panel.vue', () => ({default: {}}));
vi.mock('@/components/common/mobile_navigation.vue', () => ({default: {}}));
vi.mock('@/components/common/system_notice.vue', () => ({default: {}}));
vi.mock('@/components/common/navbar.vue', () => ({default: {}}));
vi.mock('@/components/common/error.vue', () => ({default: {}}));
vi.mock('@/components/modal/launcher.vue', () => ({default: {}}));
vi.mock('@/components/common/flash.vue', () => ({default: {}}));

import App from '@/app.vue';
import AppConfig from '@/shared/services/app_config';

describe('page titles', () => {
  let context;

  beforeEach(() => {
    document.head.innerHTML = '<title>Previous page | Loomio</title>';
    const i18n = createI18n({
      legacy: false,
      locale: 'en',
      messages: {en: {profile_page: {edit_profile: 'Edit profile'}}}
    });
    context = {pageError: {status: 404}, $t: vi.fn(i18n.global.t)};
  });

  it.each(['', null, undefined])('handles a profile with name %s and no translation key', title => {
    const options = {title, page: 'userPage'};

    expect(() => App.methods.setCurrentComponent.call(context, options)).not.toThrow();

    expect(document.title).toBe('Loomio');
    expect(context.$t).not.toHaveBeenCalled();
    expect(context.pageError).toBeNull();
    expect(AppConfig.currentGroup).toBeUndefined();
  });

  it('uses a supplied translation key when the title is empty', () => {
    App.methods.setCurrentComponent.call(context, {title: '', titleKey: 'profile_page.edit_profile'});

    expect(document.title).toBe('Edit profile | Loomio');
    expect(context.$t).toHaveBeenCalledWith('profile_page.edit_profile');
  });

  it('uses a supplied title before a translation key', () => {
    App.methods.setCurrentComponent.call(context, {title: 'Alex Morgan', titleKey: 'profile_page.edit_profile'});

    expect(document.title).toBe('Alex Morgan | Loomio');
    expect(context.$t).not.toHaveBeenCalled();
  });
});
