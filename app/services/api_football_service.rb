class ApiFootballService
  BASE_URL  = "https://v3.football.api-sports.io"
  BRAZIL_ID = 6
  COPA_LEAGUE_ID = 1

  def initialize
    @conn = Faraday.new(BASE_URL) do |f|
      f.headers["x-rapidapi-key"] = ENV.fetch("API_FOOTBALL_KEY", "")
      f.headers["x-rapidapi-host"] = "v3.football.api-sports.io"
      f.response :json
      f.adapter Faraday.default_adapter
    end
  end

  def fixture(api_id)
    response = @conn.get("/fixtures", { id: api_id })
    response.body.dig("response", 0)
  rescue Faraday::Error => e
    Rails.logger.error "[ApiFootball] fixture(#{api_id}) failed: #{e.message}"
    nil
  end

  def brazil_copa_fixtures(season: 2026)
    response = @conn.get("/fixtures", { team: BRAZIL_ID, league: COPA_LEAGUE_ID, season: season })
    response.body["response"] || []
  rescue Faraday::Error => e
    Rails.logger.error "[ApiFootball] brazil_copa_fixtures failed: #{e.message}"
    []
  end
end
