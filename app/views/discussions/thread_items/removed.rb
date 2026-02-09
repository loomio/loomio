# frozen_string_literal: true

class Views::Discussions::ThreadItems::Removed < Views::Application::Component
  def initialize(item:, current_user:)
    @item = item
    @current_user = current_user
  end

  def view_template
    div(class: "item-removed") do
      div(class: "thread-item px-3 pb-1") do
        div do
          div(class: "layout lmo-action-dock-wrapper", style: "margin-left: 0px;") do
            div(class: "thread-item__avatar mr-3 mt-0") do
              div(class: "user-avatar", style: "width: 40px; margin: 0px;", to: "/u/undefined") do
                div(class: "v-avatar", style: "height: 40px; min-width: 40px; width: 40px;") do
                  i(class: "v-icon notranslate mdi mdi-account theme--auto")
                end
              end
            end
            div(class: "layout thread-item__body column") do
              div(class: "layout align-center wrap") do
                h3(class: "thread-item__title text-body-2") do
                  span(class: "text--secondary") { plain t("thread_item.removed") }
                end
              end
            end
          end
        end
      end
    end
  end
end
