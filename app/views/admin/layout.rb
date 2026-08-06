# frozen_string_literal: true

class Views::Admin::Layout < Views::Admin::Base
  def initialize(title:)
    @title = title
  end

  def around_template(&)
    doctype
    html do
      head do
        title { "#{@title} · Loomio admin" }
        meta(charset: "utf-8")
        meta(name: "viewport", content: "width=device-width,initial-scale=1")
        meta(name: "robots", content: "noindex,nofollow")
        csrf_meta_tags
        stylesheet_link_tag "admin"
        javascript_include_tag "admin", defer: true
      end
      body(class: "admin-body") do
        div(class: "admin-shell") do
          input(id: "admin-menu-toggle", class: "admin-menu-toggle", type: "checkbox")
          aside(class: "admin-sidebar") { render_sidebar }
          div(class: "admin-content") do
            label(for: "admin-menu-toggle", class: "admin-menu-button") { "Menu" }
            render_flash
            main(class: "admin-main") { super(&) }
          end
        end
      end
    end
  end

  private

  def render_sidebar
    div(class: "admin-brand") { link_to "Loomio admin", admin_root_path }
    nav(class: "admin-nav") do
      link_to "Dashboard", admin_root_path
      link_to "Groups", admin_groups_path
      link_to "Users", admin_users_path
      link_to "Subscriptions", admin_subscriptions_path if Object.const_defined?("LoomioSubs")
      link_to "API", admin_api_path
      link_to "Jobs", "/admin/jobs"
    end
    button_to "Sign out", destroy_user_session_path, method: :delete, class: "admin-nav__sign-out"
  end

  def render_flash
    return unless flash[:notice] || flash[:alert] || flash[:error]

    message = flash[:notice] || flash[:alert] || flash[:error]
    kind = flash[:notice] ? "notice" : "error"
    div(class: "admin-flash admin-flash--#{kind}") { message }
  end
end
