require "test_helper"

class MatchTest < ActiveSupport::TestCase
  def setup
    @admin = create_admin
    @pool  = create_pool(creator: @admin)
  end

  test "is valid with home_team, away_team, kickoff_at and pool" do
    match = create_match(pool: @pool)
    assert match.valid?
  end

  test "is invalid without home_team" do
    match = @pool.matches.build(away_team: "Argentina", kickoff_at: 2.hours.from_now)
    assert_not match.valid?
  end

  test "is invalid without kickoff_at" do
    match = @pool.matches.build(home_team: "Brasil", away_team: "Argentina")
    assert_not match.valid?
  end

  test "bets_open? returns true when scheduled and kickoff > 10 min" do
    match = create_match(pool: @pool, kickoff_at: 30.minutes.from_now)
    assert match.bets_open?
  end

  test "bets_open? returns false when kickoff within 10 minutes" do
    match = create_match(pool: @pool, kickoff_at: 5.minutes.from_now)
    assert_not match.bets_open?
  end

  test "bets_open? returns false when match is finished" do
    match = create_match(pool: @pool, kickoff_at: 1.hour.ago)
    match.update!(status: "finished", home_score: 1, away_score: 0)
    assert_not match.bets_open?
  end

  test "total_prize sums confirmed payments" do
    user  = create_user
    create_approved_membership(pool: @pool, user: user)
    match = create_match(pool: @pool)
    bet   = create_bet(match: match, user: user)
    bet.payment.confirm!
    assert_equal @pool.min_bet_amount, match.total_prize
  end

  test "winning_bets returns bets that match the score" do
    user  = create_user
    create_approved_membership(pool: @pool, user: user)
    match = create_match(pool: @pool)
    bet   = create_bet(match: match, user: user, home_score: 2, away_score: 1)
    bet.payment.confirm!
    match.update!(status: "finished", home_score: 2, away_score: 1)
    assert_includes match.winning_bets, bet
  end

  test "finished match requires scores" do
    match = @pool.matches.build(home_team: "Brasil", away_team: "Argentina",
                                kickoff_at: 1.hour.ago, status: "finished")
    assert_not match.valid?
    assert match.errors.where(:base, :scores_required_when_finished).any?
  end
end
