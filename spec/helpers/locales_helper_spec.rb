require 'spec_helper'

describe LocalesHelper do
  describe '#browser_accepted_locale_strings' do
    let(:fake_env) { {'HTTP_ACCEPT_LANGUAGE' => 'pt-BR,pt;q=0.8,en-US;q=0.6,en;q=0.4,es;q=0.2'} }

    before do
      helper.stub_chain(:request, :env).and_return(fake_env)
    end

    it 'gives the correct language preference' do
      helper.browser_accepted_locale_strings.should == ['pt-BR', 'pt', 'en-US', 'en', 'es']
    end
  end
end
