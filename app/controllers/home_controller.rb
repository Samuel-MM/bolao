class HomeController < ApplicationController
  def index
    if current_user.admin?
      redirect_to admin_dashboard_path
    else
      @memberships = current_user.pool_memberships.includes(:pool).order(created_at: :desc)
      @recent_bets = current_user.bets.includes(:payment, match: :pool).order(created_at: :desc).limit(5)
    end
  end
end
