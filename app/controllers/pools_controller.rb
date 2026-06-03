class PoolsController < ApplicationController
  def show
    @pool = Pool.find(params[:id])
    require_approved_membership!(@pool)
    @matches = @pool.matches.order(:kickoff_at)
  end

  def invite
    @pool = Pool.find_by!(invite_token: params[:invite_token])
    @existing_membership = @pool.pool_memberships.find_by(user: current_user)
  end
end
