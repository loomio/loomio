class GeoLocationWorker
  include Sidekiq::Worker

  def perform()
    max_loops = User.where(country: nil).where("current_sign_in_ip is not null").count / 100
    loops = 0
    while(loops < max_loops + 1)
      loops += 1
      id_ip = User.where(country: nil).where("current_sign_in_ip is not null")
            .limit(100).pluck(:id, :current_sign_in_ip)
            .map {|pair| [pair[0], pair[1].to_s] }.filter {|pair| pair[1].length > 12 }.to_h
      res = HTTParty.post("http://ip-api.com/batch?fields=country,city", {body: id_ip.values.to_json})
      return if res.headers['x-rl'].to_i < 2
      id_ip.each_with_index do |pair, index|
        User.find(pair[0]).update_columns(country: res[index]["country"], city: res[index]["city"])
      end
    end
  end
end
