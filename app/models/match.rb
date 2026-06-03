class Match < ApplicationRecord
  belongs_to :pool
  has_many :bets, dependent: :destroy

  enum :status, { scheduled: "scheduled", live: "live", finished: "finished", cancelled: "cancelled" }

  validates :home_team, :away_team, :kickoff_at, presence: true
  validate :scores_present_when_finished

  def bets_open?
    scheduled? && kickoff_at > 10.minutes.from_now
  end

  def bets_closed?
    !bets_open?
  end

  def total_prize
    bets.joins(:payment).where(payments: { status: "confirmed" }).sum("payments.amount")
  end

  def winning_bets
    return Bet.none unless finished?
    bets.where(home_score: home_score, away_score: away_score)
        .joins(:payment).where(payments: { status: "confirmed" })
  end

  private

  def scores_present_when_finished
    if finished? && (home_score.nil? || away_score.nil?)
      errors.add(:base, :scores_required_when_finished)
    end
  end
end
