# frozen_string_literal: true

class Views::Groups::Index < Views::Application::Layout
  def initialize(groups:, pages:, page:, **layout_args)
    super(**layout_args)
    @groups = groups
    @pages = pages
    @page = page
  end

  def view_template
    div(class: "explore-page mt-12") do
      main(class: "container") do
        h1(class: "pt-4") { plain t(:"sidebar.find_a_group") }
        div(class: "v-main") do
          div(class: "v-main__wrap") do
            div(class: "container explore-page max-width-1024 px-0 px-sm-3") do
              div(class: "row explore-page__groups my-4") do
                @groups.each do |group|
                  render_group_card(group)
                end
              end
              render_pagination
            end
          end
        end
      end
    end
  end

  private

  def render_group_card(group)
    div(class: "col-sm-12 col-md-6 col-lg-6 col") do
      a(class: "explore-page__group my-4 v-card v-card--link v-sheet theme--auto", href: group_url(group)) do
        div(class: "v-responsive v-image explore-page__group-cover") do
          div(class: "v-responsive__sizer", style: "padding-bottom: 20.6186%;")
          div(class: "v-image__image v-image__image--cover", style: "background-image: url(#{group.logo_url}); background-position: center center;")
          div(class: "v-responsive__content", style: "width: 970px;")
        end
        div(class: "v-card__title") { plain group.name }
        div(class: "v-card__text") do
          div(class: "explore-page__group-description") do
            plain MarkdownService.render_plain_text(group.description, group.description_format).truncate(100)
          end
          div(class: "layout explore-page__group-stats justify-start align-center") do
            i(class: "v-icon notranslate mr-2 mdi mdi-account-multiple theme--auto")
            span(class: "mr-4") { plain group.memberships_count.to_s }
            i(class: "v-icon notranslate mr-2 mdi mdi-comment-text-outline theme--auto")
            span(class: "mr-4") { plain group.discussions_count.to_s }
            i(class: "v-icon notranslate mr-2 mdi mdi-thumbs-up-down theme--auto")
            span(class: "mr-4") { plain group.polls_count.to_s }
          end
        end
      end
    end
  end

  def render_pagination
    div(class: "row align-center justify-center") do
      span { plain "<" }
      (1..@pages).each do |p|
        plain " "
        a(href: "/explore?q=&page=#{p}&export=1") { plain p.to_s }
        plain " "
      end
      span { plain ">" }
    end
  end
end
