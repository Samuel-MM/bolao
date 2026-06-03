module Admin
  class DashboardController < BaseController
    def index
      @pools          = Pool.order(created_at: :desc).limit(5)
      @pending_memberships = PoolMembership.pending.includes(:user, :pool).order(created_at: :desc).limit(10)
      @pending_payments    = Payment.submitted.includes(bet: [:user, { match: :pool }]).order(created_at: :desc).limit(10)
      @refund_requests     = Payment.where.not(refund_requested_at: nil)
                                    .where(refund_processed_at: nil)
                                    .includes(bet: [:user, { match: :pool }])
                                    .order(refund_requested_at: :asc)
    end
  end
end
