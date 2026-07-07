class HelpController < ApplicationController
  def markdown
    render layout: false
  end

  def api2
    current_user.save if current_user.api_key_changed?
    render_api_doc "b2", api2_doc_values
  end

  def api3
    render_api_doc "b3", root_url: root_url
  end

  def whats_new
    render Views::Help::WhatsNew.new(updates: whats_new_updates)
  end

  private

  def whats_new_updates
    Dir.glob(Rails.root.join("docs", "user_manual", "updates", "*.md")).sort.reverse.map do |path|
      date = Date.parse(File.basename(path)[0, 10]).strftime("%B %-e, %Y")
      { date: date, html: MarkdownService.render_html(File.read(path)) }
    end
  end

  def render_api_doc(name, values = {})
    markdown = Rails.root.join("docs", "api", "#{name}.md").read
    values.each do |key, value|
      markdown = markdown.gsub("{{#{key}}}", value.to_s)
    end

    render Views::Help::Markdown.new(markdown: markdown)
  end

  def api2_doc_values
    group_id = params[:group_id] || 123
    {
      api_key: current_user.api_key,
      bot_account_note: bot_account_note,
      group_id: group_id,
      email: current_user.email,
      root_url: root_url,
      closing_at: 7.days.from_now.at_beginning_of_hour.utc.iso8601,
      admin_groups: admin_groups_markdown
    }
  end

  def bot_account_note
    if current_user.bot?
      "This user account is a bot. That's good. It will not be included in polls and notifications"
    else
      "This user account is not marked as \"bot\". This means it will be issued votes and expected to participate in decision. " \
        "You may want to [set up a bot account](/profile) for API requests. Bot accounts are not issued votes or considered when calculating poll results."
    end
  end

  def admin_groups_markdown
    rows = current_user.adminable_groups.map do |group|
      "| #{group.id} | [#{markdown_table_text(group.full_name)}](?group_id=#{group.id}) |"
    end

    return "_No adminable groups found_" if rows.empty?

    [
      "| ID | Group |",
      "| --- | --- |",
      rows
    ].flatten.join("\n")
  end

  def markdown_table_text(text)
    text.to_s.gsub("|", "\\|")
  end
end
