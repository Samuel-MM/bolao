module Admin
  class PoolMembershipsController < BaseController
    before_action :set_pool
    before_action :set_membership, only: [:approve, :reject]

    def index
      @memberships = @pool.pool_memberships.includes(:user).order(created_at: :desc)
    end

    def approve
      @membership.approve!
      ParticipantMailer.approved(@membership).deliver_later
      redirect_to admin_pool_pool_memberships_path(@pool), notice: "#{@membership.user.name} aprovado."
    end

    def reject
      @membership.reject!
      ParticipantMailer.rejected(@membership).deliver_later
      redirect_to admin_pool_pool_memberships_path(@pool), notice: "#{@membership.user.name} rejeitado."
    end

    private

    def set_pool
      @pool = Pool.find(params[:pool_id])
    end

    def set_membership
      @membership = @pool.pool_memberships.find(params[:id])
    end
  end
end
