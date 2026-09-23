# frozen_string_literal: true

class Views::Profile::ApiAccess < Views::BasicLayout
  def initialize(api_key:, groups:)
    super(
      title: "API access",
      description: "Your Loomio User API key and group IDs",
      robots: "noindex,nofollow"
    )
    @api_key = api_key
    @groups = groups
  end

  def view_template
    style do
      raw <<~CSS.html_safe
        .api-access {
          margin: 2rem auto 4rem;
          max-width: 52rem;
          padding: 0 1rem;
        }

        .api-access__card {
          background: white;
          border-radius: 0.75rem;
          box-shadow: 0 1px 3px rgba(0, 0, 0, 0.16);
          margin-top: 1rem;
          padding: 1.5rem;
        }

        .api-access__key,
        .api-access__example {
          background: #f4f4f4;
          border-radius: 0.25rem;
          display: block;
          overflow-wrap: anywhere;
          padding: 0.75rem;
          white-space: pre-wrap;
        }

        .api-access__groups {
          border-collapse: collapse;
          width: 100%;
        }

        .api-access__groups th,
        .api-access__groups td {
          border-bottom: 1px solid #ddd;
          padding: 0.75rem 0.5rem;
          text-align: left;
        }

        .api-access__links li {
          margin-bottom: 0.5rem;
        }
      CSS
    end

    main(class: "api-access") do
      h1 { "API access" }
      p { "Use this page to find the credentials and group IDs needed for the Loomio User API." }

      section(class: "api-access__card", aria_labelledby: "api-key-heading") do
        h2(id: "api-key-heading") { "Your API key" }
        code(class: "api-access__key") { @api_key }
        p { "Treat this key like a password. Requests made with it have the same access and permissions as your account." }
        p { "Your API key rotates when you change your password. Update your integrations with the new key after changing your password." }

        h3 { "Bearer authentication" }
        p { "Send the key in the Authorization header:" }
        code(class: "api-access__example") { "Authorization: Bearer YOUR_API_KEY" }

        h3 { "Change from API key query parameters" }
        p { "API keys are no longer accepted in URL query parameters because URLs can be recorded in browser history, proxy logs, and server access logs." }
        p do
          plain "Requests using "
          code { "?api_key=YOUR_API_KEY" }
          plain " no longer work. Use "
          code { "Authorization: Bearer YOUR_API_KEY" }
          plain " instead."
        end
      end

      section(class: "api-access__card", aria_labelledby: "group-ids-heading") do
        h2(id: "group-ids-heading") { "Your group IDs" }
        if @groups.any?
          table(class: "api-access__groups") do
            thead do
              tr do
                th(scope: "col") { "Group" }
                th(scope: "col") { "ID" }
              end
            end
            tbody do
              @groups.each do |group|
                tr do
                  td { a(href: "/g/#{group.key}") { group.name } }
                  td { code { group.id.to_s } }
                end
              end
            end
          end
        else
          p { "You do not belong to any active groups." }
        end
      end

      section(class: "api-access__card", aria_labelledby: "documentation-heading") do
        h2(id: "documentation-heading") { "Documentation" }
        ul(class: "api-access__links") do
          li { a(href: "/docs/en/user_manual/integrations/api/user-api") { "User API documentation" } }
          li { a(href: "/docs/en/user_manual/integrations/api") { "API overview" } }
          li { a(href: "/docs/en/user_manual/integrations/api/server-api") { "Server API documentation" } }
        end
      end
    end
  end

  private

  def render_head
    super
    meta(name: "referrer", content: "no-referrer")
  end

  def render_plausible
  end
end
