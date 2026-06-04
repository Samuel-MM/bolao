class FootballDataService
  BASE_URL = "https://api.football-data.org/v4/"

  def initialize
    @conn = Faraday.new(BASE_URL) do |f|
      f.headers["X-Auth-Token"] = ENV.fetch("FOOTBALL_DATA_API_KEY", "")
      f.response :json
      f.adapter Faraday.default_adapter
    end
  end

  # Returns the raw match object or nil
  def match(id)
    response = @conn.get("matches/#{id}")
    log_rate_limit(response)
    return nil unless response.status == 200
    response.body
  rescue Faraday::Error => e
    Rails.logger.error "[FootballData] match(#{id}) failed: #{e.message}"
    nil
  end

  # Returns array of match objects for a competition
  def competition_matches(competition: "WC", season: 2026)
    response = @conn.get("competitions/#{competition}/matches", { season: season })
    log_rate_limit(response)
    return [] unless response.status == 200
    response.body["matches"] || []
  rescue Faraday::Error => e
    Rails.logger.error "[FootballData] competition_matches failed: #{e.message}"
    []
  end

  private

  def log_rate_limit(response)
    remaining = response.headers["X-Requests-Available-Minute"]
    Rails.logger.warn "[FootballData] Rate limit: #{remaining} req/min remaining" if remaining.to_i < 3
  end
end
