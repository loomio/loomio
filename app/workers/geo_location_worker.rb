class GeoLocationWorker
  include Sidekiq::Worker

  def perform
    db_filename = Rails.root.join('public', 'GeoLite2-Country.mmdb').to_s

    unless File.exist? db_filename
      # from https://github.com/P3TERX/GeoLite.mmdb
      download = URI.parse("https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-Country.mmdb").open
      IO.copy_stream(download, db_filename)
      puts "downloaded maxmind db"
    end

    db = MaxMindDB.new(db_filename)
    User.where(country: nil).where("current_sign_in_ip is not null").find_each do |user|
      record = db.lookup(user.current_sign_in_ip.to_s)
      next unless record.found?
      user.update_columns(country: record.country.name)
    end
  end
end
