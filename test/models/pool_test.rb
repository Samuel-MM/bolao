require "test_helper"

class PoolTest < ActiveSupport::TestCase
  def setup
    @admin = create_admin
  end

  test "is valid with name, min_bet_amount and creator" do
    pool = create_pool(creator: @admin)
    assert pool.valid?
  end

  test "is invalid without name" do
    pool = Pool.new(min_bet_amount: 20, creator: @admin)
    assert_not pool.valid?
    assert pool.errors.where(:name, :blank).any?
  end

  test "generates invite_token on create" do
    pool = create_pool(creator: @admin)
    assert pool.invite_token.present?
  end

  test "invite_token is unique" do
    pool1 = create_pool(creator: @admin)
    pool2 = Pool.new(name: "Outro", min_bet_amount: 10, creator: @admin, invite_token: pool1.invite_token)
    assert_not pool2.valid?
  end

  test "default status is open" do
    pool = create_pool(creator: @admin)
    assert pool.open?
  end

  test "can be finished" do
    pool = create_pool(creator: @admin)
    pool.finished!
    assert pool.finished?
  end

  test "member? returns true for approved member" do
    pool = create_pool(creator: @admin)
    user = create_user
    create_approved_membership(pool: pool, user: user)
    assert pool.member?(user)
  end

  test "member? returns false for pending member" do
    pool = create_pool(creator: @admin)
    user = create_user
    pool.pool_memberships.create!(user: user)
    assert_not pool.member?(user)
  end
end
