require "test_helper"

class BetTest < ActiveSupport::TestCase
  def setup
    @admin = create_admin
    @pool  = create_pool(creator: @admin)
    @user  = create_user
    create_approved_membership(pool: @pool, user: @user)
    @match = create_match(pool: @pool, kickoff_at: 2.hours.from_now)
  end

  test "is valid for approved member while bets are open" do
    bet = @match.bets.build(user: @user, home_score: 2, away_score: 0)
    assert bet.valid?
  end

  test "is invalid when bets are closed" do
    @match.update_column(:kickoff_at, 5.minutes.from_now)
    bet = @match.bets.build(user: @user, home_score: 1, away_score: 0)
    assert_not bet.valid?
    assert bet.errors.where(:base, :bets_closed).any?
  end

  test "is invalid for non-member" do
    stranger = create_user
    bet = @match.bets.build(user: stranger, home_score: 1, away_score: 0)
    assert_not bet.valid?
    assert bet.errors.where(:base, :not_a_member).any?
  end

  test "same scoreline cannot be bet twice by the same user on the same match" do
    create_bet(match: @match, user: @user, home_score: 2, away_score: 1)
    duplicate = @match.bets.build(user: @user, home_score: 2, away_score: 1)
    assert_not duplicate.valid?
    assert duplicate.errors.where(:base, :duplicate_scoreline).any?
  end

  test "same scoreline can be bet again after refund is processed" do
    bet = create_bet(match: @match, user: @user, home_score: 2, away_score: 1)
    bet.payment.process_refund!
    assert bet.reload.cancelled?
    new_bet = @match.bets.build(user: @user, home_score: 2, away_score: 1)
    assert new_bet.valid?, new_bet.errors.full_messages.inspect
  end

  test "same user can bet different scorelines on same match" do
    bet1 = create_bet(match: @match, user: @user, home_score: 2, away_score: 1)
    bet2 = @match.bets.build(user: @user, home_score: 3, away_score: 0)
    assert bet2.valid?
  end

  test "creates a payment after save" do
    bet = create_bet(match: @match, user: @user, home_score: 1, away_score: 0)
    assert bet.payment.present?
    assert_equal @pool.min_bet_amount, bet.payment.amount
  end

  test "is invalid with negative scores" do
    bet = @match.bets.build(user: @user, home_score: -1, away_score: 0)
    assert_not bet.valid?
  end
end
