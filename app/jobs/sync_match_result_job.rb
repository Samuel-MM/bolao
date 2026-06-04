class SyncMatchResultJob < ApplicationJob
  queue_as :default

  def perform(match_id)
    match = Match.find(match_id)
    return if match.finished? || match.cancelled?
    return unless match.api_football_id.present?

    data = FootballDataService.new.match(match.api_football_id)
    return unless data

    api_status = data["status"]
    # API v4 uses "home"/"away"; fall back to "homeTeam"/"awayTeam" for older responses
    home_score = data.dig("score", "fullTime", "home") || data.dig("score", "fullTime", "homeTeam")
    away_score = data.dig("score", "fullTime", "away") || data.dig("score", "fullTime", "awayTeam")

    case api_status
    when "FINISHED"
      match.update!(status: "finished", home_score: home_score, away_score: away_score)
      MatchResultJob.perform_later(match.id)
    when "IN_PLAY", "PAUSED", "LIVE"
      match.update!(status: "live")
    when "POSTPONED", "SUSPENDED", "CANCELLED"
      match.update!(status: "cancelled")
    end
  end
end
