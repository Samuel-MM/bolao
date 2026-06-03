ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all

    private

    def create_user(overrides = {})
      User.create!({
        name: "Participante Teste",
        email: "user#{SecureRandom.hex(4)}@example.com",
        password: "password123",
        password_confirmation: "password123"
      }.merge(overrides))
    end

    def create_admin(overrides = {})
      create_user(overrides.merge(role: "admin"))
    end

    def create_pool(creator:, **overrides)
      Pool.create!({
        name: "Bolão Copa 2026",
        min_bet_amount: 20.0,
        creator: creator
      }.merge(overrides))
    end

    def create_approved_membership(pool:, user:)
      pool.pool_memberships.create!(user: user, status: "approved", approved_at: Time.current)
    end

    def create_match(pool:, **overrides)
      Match.create!({
        pool: pool,
        home_team: "Brasil",
        away_team: "Argentina",
        kickoff_at: 2.hours.from_now
      }.merge(overrides))
    end

    def create_bet(match:, user:, home_score: 2, away_score: 1)
      Bet.create!(match: match, user: user, home_score: home_score, away_score: away_score)
    end
  end
end
