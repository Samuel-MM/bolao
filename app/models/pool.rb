class Pool < ApplicationRecord
  belongs_to :creator, class_name: "User"
  has_many :pool_memberships, dependent: :destroy
  has_many :members, through: :pool_memberships, source: :user
  has_many :approved_memberships, -> { approved }, class_name: "PoolMembership"
  has_many :approved_members, through: :approved_memberships, source: :user
  has_many :matches, dependent: :destroy

  enum :status, { open: "open", finished: "finished" }

  validates :name, presence: true
  validates :min_bet_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :invite_token, presence: true, uniqueness: true

  before_validation :generate_invite_token, on: :create

  def member?(user)
    pool_memberships.approved.exists?(user: user)
  end

  private

  def generate_invite_token
    self.invite_token ||= SecureRandom.urlsafe_base64(16)
  end
end
