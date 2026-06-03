class PoolMembership < ApplicationRecord
  belongs_to :pool
  belongs_to :user

  enum :status, { pending: "pending", approved: "approved", rejected: "rejected" }

  validates :user_id, uniqueness: { scope: :pool_id, message: :already_member }

  def approve!
    update!(status: "approved", approved_at: Time.current)
  end

  def reject!
    update!(status: "rejected")
  end
end
