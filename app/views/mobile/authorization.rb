# frozen_string_literal: true

class Views::Mobile::Authorization < Views::BasicLayout
  include Phlex::Rails::Helpers::FormTag

  def initialize(user:, host:)
    super(title: I18n.t("mobile_auth.authorize.title"), robots: "noindex,nofollow")
    @user = user
    @host = host
  end

  def view_template
    style do
      plain <<~CSS
        .mobile-auth { margin: 2rem auto 4rem; max-width: 34rem; padding: 0 1rem; }
        .mobile-auth__card { background: white; border-radius: .75rem; box-shadow: 0 1px 3px rgba(0,0,0,.16); padding: 1.5rem; }
        .mobile-auth__account { background: #f4f4f4; border-radius: .5rem; margin: 1rem 0; padding: 1rem; }
        .mobile-auth__actions { display: flex; flex-wrap: wrap; gap: .75rem; margin-top: 1.5rem; }
        .mobile-auth__button { border: 0; border-radius: .3rem; cursor: pointer; font: inherit; padding: .7rem 1rem; }
        .mobile-auth__button--approve { background: var(--loomio-primary-color); color: var(--loomio-primary-text-color); }
        .mobile-auth__button--deny { background: #eee; color: #222; }
      CSS
    end

    main(class: "mobile-auth") do
      section(class: "mobile-auth__card", aria_labelledby: "mobile-auth-heading") do
        h1(id: "mobile-auth-heading") { I18n.t("mobile_auth.authorize.heading") }
        p { I18n.t("mobile_auth.authorize.introduction", host: @host) }
        div(class: "mobile-auth__account") do
          strong { @user.name }
          br
          span { @user.email }
        end
        p { I18n.t("mobile_auth.authorize.access") }
        ul do
          li { I18n.t("mobile_auth.authorize.activity") }
          li { I18n.t("mobile_auth.authorize.notifications") }
          li { I18n.t("mobile_auth.authorize.web_session") }
        end
        form_tag(mobile_authorize_path, method: :post) do
          div(class: "mobile-auth__actions") do
            button(type: "submit", name: "decision", value: "approve", class: "mobile-auth__button mobile-auth__button--approve") do
              I18n.t("mobile_auth.authorize.approve")
            end
            button(type: "submit", name: "decision", value: "deny", class: "mobile-auth__button mobile-auth__button--deny") do
              I18n.t("mobile_auth.authorize.deny")
            end
          end
        end
      end
    end
  end

  private

  def render_plausible
  end
end
