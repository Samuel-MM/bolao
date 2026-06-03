class SyncMatchResultJob < ApplicationJob
  queue_as :default

  def perform(match_id)
    match = Match.find(match_id)
    return if match.finished? || match.cancelled?
    return unless match.api_football_id.present?

    fixture = ApiFootballService.new.fixture(match.api_football_id)
    return unless fixture

    api_status  = fixture.dig("fixture", "status", "short")
    home_score  = fixture.dig("goals", "home")
    away_score  = fixture.dig("goals", "away")

    case api_status
    when "FT", "AET", "PEN"
      match.update!(status: "finished", home_score: home_score, away_score: away_score)
      MatchResultJob.perform_later(match.id)
    when "1H", "HT", "2H", "ET", "BT", "P"
      match.update!(status: "live")
    when "CANC", "ABD", "AWD", "WO"
      match.update!(status: "cancelled")
    end
  end
end
