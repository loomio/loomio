# frozen_string_literal: true

class Views::Application::Footer < Views::Application::Component
  def initialize(class_names: nil, branding: true)
    @class_names = class_names
    @branding = branding
  end

  def view_template
    footer(class: @class_names) do
      div(class: "text-center") do
        div(class: "powered-by caption text-medium-emphasis") do
          links = [
            [AppConfig.theme[:privacy_url], t(:"powered_by.privacy_policy")],
            [AppConfig.theme[:terms_url], t(:"powered_by.terms_of_service")]
          ].select { |url, _text| url.present? }

          if @branding
            a(class: "text-medium-emphasis", href: about_loomio_path) { plain t(:"powered_by.powered_by_loomio") }
            plain " · " if links.any?
          end

          links.each_with_index do |(url, text), index|
            plain " · " if index.positive?
            a(class: "text-medium-emphasis", href: url, target: "_blank") { plain text }
          end
        end
      end
    end
  end
end
