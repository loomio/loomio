class AddHeadingIdsWorker
  include Sidekiq::Worker

  def perform()
    {
      Discussion => 'description',
      Comment => 'body',
      Poll => 'details',
      Outcome => 'statement',
      Stance => 'reason',
      Group => 'description'
    }.each_pair do |model, field|
      rel = model.where("#{field}_format": 'html').where("#{field} is not null and #{field} != ''")
      puts "Updating #{rel.count} #{model.to_s.pluralize}"
      rel.find_each do |r|
        model.where(id: r.id).update_all(field => HasRichText::add_heading_ids(r[field]))
      end
    end
  end
end
