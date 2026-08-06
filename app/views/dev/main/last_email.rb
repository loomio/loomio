# frozen_string_literal: true

class Views::Dev::Main::LastEmail < Phlex::HTML
  def initialize(email:, scenario:, action_name:)
    @email = email
    @scenario = scenario
    @action_name = action_name
  end

  def view_template
    doctype
    html do
      head { title { @action_name } }
      body { render_email }
    end
  end

  private

  def render_email
    if @email.nil?
      p(class: "error") { "no emails sent" }
      return
    end

    render_i18n_params if @scenario
    table do
      email_row("To", Array(@email.to).join(", "))
      email_row("From", Array(@email.from).join(", "))
      email_row("Subject", @email.subject)
      email_row("Reply to", Array(@email.reply_to).join(", "))
    end
    hr
    email_html = @email.html_part&.decoded || @email.body.decoded
    main(style: "margin: 8px") { raw email_html.html_safe }
  end

  def render_i18n_params
    div(class: "i18n-params", style: "display: none") do
      div(class: "group") { @scenario[:group]&.name }
      div(class: "discussion") { @scenario[:discussion]&.title }
      div(class: "actor") { @scenario[:actor]&.name }
      div(class: "poll") { @scenario[:poll]&.title }
      div(class: "title") { @scenario[:poll]&.title }
      div(class: "poll_type") { I18n.t("poll_types.#{@scenario[:poll]&.poll_type}") }
    end
  end

  def email_row(label, value)
    tr do
      td { label }
      td { value }
    end
  end
end
