require "test_helper"

class PoolMembershipTest < ActiveSupport::TestCase
  def setup
    @admin = create_admin
    @pool  = create_pool(creator: @admin)
    @user  = create_user
  end

  test "is valid with pool and user" do
    membership = @pool.pool_memberships.build(user: @user)
    assert membership.valid?
  end

  test "default status is pending" do
    membership = @pool.pool_memberships.create!(user: @user)
    assert membership.pending?
  end

  test "user cannot have two memberships in the same pool" do
    @pool.pool_memberships.create!(user: @user)
    duplicate = @pool.pool_memberships.build(user: @user)
    assert_not duplicate.valid?
  end

  test "approve! changes status to approved and sets approved_at" do
    membership = @pool.pool_memberships.create!(user: @user)
    membership.approve!
    assert membership.approved?
    assert membership.approved_at.present?
  end

  test "reject! changes status to rejected" do
    membership = @pool.pool_memberships.create!(user: @user)
    membership.reject!
    assert membership.rejected?
  end
end
