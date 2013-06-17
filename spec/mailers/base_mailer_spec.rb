require "spec_helper"

describe BaseMailer do
  describe ".set_email_locale(preference, fallback)" do
    context "if preference is not nil" do
      it "sets the locale to preference" do
        I18n.should_receive(:locale=).with("es")
        BaseMailer.set_email_locale("es", "en")
      end
    end
    context "if preference is an empty string" do
      it "does not set the locale to preference" do
        I18n.should_not_receive(:locale=).with("")
        BaseMailer.set_email_locale("", "en")
      end
    end
    context "if preference is nil and fallback is nil" do
      it "sets the locale to default" do
        I18n.should_receive(:locale=).with(I18n.default_locale)
        BaseMailer.set_email_locale(nil, nil)
      end
    end
    context "if preference is nil and fallback is not nil" do
      it "sets the locale to fallback" do
        I18n.should_receive(:locale=).with("de")
        BaseMailer.set_email_locale(nil, "de")
      end
    end
    context "if fallback is an empty string" do
      it "does not set the locale to fallback" do
        I18n.should_not_receive(:locale=).with("")
        BaseMailer.set_email_locale("", "")
      end
    end
  end
end
