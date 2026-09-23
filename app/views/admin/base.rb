# frozen_string_literal: true

class Views::Admin::Base < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::Rails::Helpers::Flash
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::CSRFMetaTags
  include Phlex::Rails::Helpers::StyleSheetLinkTag
  include Phlex::Rails::Helpers::URLFor
  include Phlex::Rails::Helpers::JavaScriptIncludeTag

  private

  def page_header(title, action_label: nil, action_path: nil)
    header(class: "admin-page-header") do
      h1 { title }
      link_to(action_label, action_path, class: "admin-button") if action_label && action_path
    end
  end

  def panel(title, class_name: nil, &)
    section(class: [ "admin-panel", class_name ].compact.join(" ")) do
      h2 { title }
      div(class: "admin-panel__body", &)
    end
  end

  def value(value)
    value.present? ? value.to_s : "—"
  end

  def pagination_links(pagination, filters)
    return if pagination[:page_count] <= 1

    nav(class: "admin-pagination", aria: { label: "Pagination" }) do
      if pagination[:page] > 1
        link_to "Previous", url_for(filters.to_h.merge(page: pagination[:page] - 1)), class: "admin-button admin-button--secondary"
      end
      span { "Page #{pagination[:page]} of #{pagination[:page_count]} (#{pagination[:count]} records)" }
      if pagination[:page] < pagination[:page_count]
        link_to "Next", url_for(filters.to_h.merge(page: pagination[:page] + 1)), class: "admin-button admin-button--secondary"
      end
    end
  end

  def definition_list(record, keys)
    dl(class: "admin-definition-list") do
      keys.each do |key|
        div do
          dt { key.to_s.humanize }
          dd { value(record.public_send(key)) }
        end
      end
    end
  end

  def form_errors(record, title:)
    return if record.errors.empty?

    div(class: "admin-form-errors", role: "alert") do
      strong { title }
      ul do
        record.errors.full_messages.each { |message| li { message } }
      end
      yield if block_given?
    end
  end

  def field(form, name, type: :text_field, **options)
    div(class: "admin-field") do
      form.label(name)
      form.public_send(type, name, **options)
    end
  end

  def select_field(form, name, choices)
    div(class: "admin-field") do
      form.label(name)
      form.select(name, choices)
    end
  end

  def checkbox_field(form, name, label: nil)
    label(class: "admin-checkbox") do
      form.check_box(name)
      span { label || name.to_s.humanize }
    end
  end
end
