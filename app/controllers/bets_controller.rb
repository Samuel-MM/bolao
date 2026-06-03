class BetsController < ApplicationController
  before_action :set_pool_and_match, only: [:new, :create]

  def index
    @bets = current_user.bets.includes(:payment, match: :pool).order(created_at: :desc)
  end

  def show
    @bet     = current_user.bets.find(params[:id])
    @payment = @bet.payment
    @match   = @bet.match
    @pool    = @match.pool
  end

  def new
    require_approved_membership!(@pool)
    @bet = @match.bets.build
  end

  def create
    require_approved_membership!(@pool)

    @bet = @match.bets.build(bet_params.merge(user: current_user))

    if @bet.save
      redirect_to payment_path(@bet.payment), notice: "Aposta registrada! Efetue o pagamento via PIX."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_pool_and_match
    @pool  = Pool.find(params[:pool_id])
    @match = @pool.matches.find(params[:match_id])
  end

  def bet_params
    params.require(:bet).permit(:home_score, :away_score)
  end
end
