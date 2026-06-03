class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :authenticate_user!, unless: :devise_controller?
  before_action :force_html_format

  helper_method :admin?

  private

  def force_html_format
    request.format = :html if request.format.turbo_stream?
  end

  def admin?
    current_user&.admin?
  end

  def require_approved_membership!(pool)
    membership = pool.pool_memberships.find_by(user: current_user)
    unless membership&.approved?
      redirect_to root_path, alert: "Você não é membro aprovado deste bolão."
    end
  end
end
