module Admin
  class BaseController < ApplicationController
    layout "admin"

    before_action :require_admin!
    before_action :force_html_format

    private

    def require_admin!
      unless current_user&.admin?
        redirect_to root_path, alert: "Acesso restrito a administradores."
      end
    end

    def force_html_format
      request.format = :html if request.format.turbo_stream?
    end
  end
end
