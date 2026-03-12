namespace :demo do
  desc "Export a group as demo data to db/demo/demo.json"
  task export: :environment do
    group_id = ENV.fetch('GROUP_ID') { abort "Usage: rake demo:export GROUP_ID=123 [RECORDED_AT=2025-01-15T10:00:00Z]" }
    recorded_at = ENV.fetch('RECORDED_AT', Time.now.iso8601)

    group = Group.find(group_id)
    groups = [group] + group.subgroups.published
    filename = GroupExportService.export(groups, group.name)

    dest = Rails.root.join('db/demo/demo.json')
    FileUtils.cp(filename, dest)

    metadata = { 'recorded_at' => recorded_at }
    File.write(Rails.root.join('db/demo/metadata.yml'), metadata.to_yaml)

    puts "Exported group #{group.name} (#{group_id}) to db/demo/demo.json"
    puts "Recorded at: #{recorded_at}"
    puts "Records: #{File.readlines(dest).size} lines"
  end
end
