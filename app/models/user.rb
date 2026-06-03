class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { participant: "participant", admin: "admin" }

  validates :name, presence: true

  has_many :created_pools, class_name: "Pool", foreign_key: :creator_id, dependent: :destroy
  has_many :pool_memberships, dependent: :destroy
  has_many :pools, through: :pool_memberships
  has_many :bets, dependent: :destroy
end
