class MatchesController < ApplicationController
  before_action :set_pool_and_match

  def show
    require_approved_membership!(@pool)
    @user_bets = @match.bets.where(user: current_user).includes(:payment)
    @bets_open = @match.bets_open?

    if @match.finished?
      @all_bets    = @match.bets.includes(:payment, :user).order(created_at: :asc)
      @winning_bets = @match.winning_bets
    end
  end

  private

  def set_pool_and_match
    @pool  = Pool.find(params[:pool_id])
    @match = @pool.matches.find(params[:id])
  end
end
