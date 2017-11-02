require 'spec_helper'
require 'rails_helper'

describe LocalesHelper do
  let(:http_no_lang) { { 'HTTP_ACCEPT_LANGUAGE' => '' } }
  let(:http_accept_lang) { {'HTTP_ACCEPT_LANGUAGE' => 'pt-BR,pt;q=0.8,en-US;q=0.6,en;q=0.4,es;q=0.2'} }
  let(:http_accept_lang_fallback) {{ 'HTTP_ACCEPT_LANGUAGE' => 'fr-fr;q=0.8'}}
  let(:http_accept_lang_bad) {{ 'HTTP_ACCEPT_LANGUAGE' => 'notagoodone' }}
  let(:user) { create :user }

  before do
    helper.stub(:request).and_return(OpenStruct.new(env: http_no_lang))
    helper.stub(:current_user).and_return(user)
  end

  describe 'preferred_locale' do
    it 'can set via query parameter' do
      helper.stub(:params).and_return(locale: 'fr')
      expect(helper.preferred_locale).to eq 'fr'
    end

    it 'does not set a bad locale via query param' do
      helper.stub(:params).and_return(lang: 'notagoodone')
      expect(helper.preferred_locale).to eq I18n.default_locale
    end

    it 'can set via user preference' do
      user.update(selected_locale: 'fr')
      expect(helper.preferred_locale).to eq 'fr'
    end

    it 'can set via browser http header' do
      # given pt-BR we return the fallback: es
      helper.stub(:request).and_return(OpenStruct.new(env: http_accept_lang))
      expect(helper.preferred_locale).to eq 'es'
    end

    it 'has robust fallbacks from browser http headers' do
      # given fr-fr we return the generalised 'fr'
      helper.stub(:request).and_return(OpenStruct.new(env: http_accept_lang_fallback))
      expect(helper.preferred_locale).to eq 'fr'
    end

    it 'does not set a bad locale via http header' do
      helper.stub(:request).and_return(OpenStruct.new(env: http_accept_lang_bad))
      expect(helper.preferred_locale).to eq I18n.default_locale
    end

    it 'uses default_locale by default' do
      expect(helper.preferred_locale).to eq I18n.default_locale
    end
  end
end
