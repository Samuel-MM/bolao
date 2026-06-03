class Payment < ApplicationRecord
  belongs_to :bet

  enum :status, {
    pending:   "pending",
    submitted: "submitted",
    confirmed: "confirmed",
    rejected:  "rejected",
    refunded:  "refunded"
  }

  validates :amount, numericality: { greater_than: 0 }

  delegate :match, :user, to: :bet

  def submit_proof!(url)
    update!(proof_url: url, status: "submitted")
  end

  def confirm!
    update!(status: "confirmed", paid_at: Time.current, approved_at: Time.current)
  end

  def reject!(reason: nil)
    update!(status: "rejected", rejection_reason: reason.presence)
  end

  def request_refund!
    raise "Jogo já começou" if bet.match.kickoff_at <= Time.current
    update!(refund_requested_at: Time.current)
  end

  def process_refund!
    update!(status: "refunded", refund_processed_at: Time.current)
    bet.cancel!
  end

  def refund_requested?
    refund_requested_at.present? && refund_processed_at.nil?
  end
end
