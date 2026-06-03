class SyncAllMatchResultsJob < ApplicationJob
  queue_as :default

  def perform
    Match.where(status: %w[scheduled live])
         .where.not(api_football_id: nil)
         .where("kickoff_at <= ?", 3.hours.from_now)
         .find_each do |match|
      SyncMatchResultJob.perform_later(match.id)
    end
  end
end
