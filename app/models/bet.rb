class Bet < ApplicationRecord
  belongs_to :match
  belongs_to :user
  has_one :payment, dependent: :destroy

  validates :home_score, :away_score, presence: true,
            numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validate :scoreline_not_duplicated
  validate :bets_must_be_open
  validate :user_must_be_approved_member

  after_create :create_payment_with_pix

  scope :active, -> { where(cancelled_at: nil) }

  def cancel!
    update!(cancelled_at: Time.current)
  end

  def cancelled?
    cancelled_at.present?
  end

  private

  def scoreline_not_duplicated
    return unless match && user && home_score.present? && away_score.present?
    duplicate = match.bets
                     .where(user: user, home_score: home_score, away_score: away_score)
                     .where(cancelled_at: nil)
                     .where.not(id: id)
                     .exists?
    errors.add(:base, :duplicate_scoreline) if duplicate
  end

  def bets_must_be_open
    errors.add(:base, :bets_closed) if match && match.bets_closed?
  end

  def user_must_be_approved_member
    return unless match && user
    unless match.pool.member?(user)
      errors.add(:base, :not_a_member)
    end
  end

  def create_payment_with_pix
    amount = match.pool.min_bet_amount
    pix_code = nil
    qr_code_svg = nil

    if (pix_key = ENV["PIX_KEY"]).present?
      pix = PixService.new(
        key: pix_key,
        name: ENV.fetch("PIX_MERCHANT_NAME", "Bolao da Copa"),
        city: ENV.fetch("PIX_MERCHANT_CITY", "Sao Paulo"),
        amount: amount,
        txid: "BET#{id}"
      )
      pix_code = pix.generate_code
      qr_code_svg = pix.generate_qr_svg
    end

    Payment.create!(bet: self, amount: amount, pix_code: pix_code, qr_code_svg: qr_code_svg)
  end
end
