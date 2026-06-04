module Admin
  class BetsController < BaseController
    before_action :set_pool
    before_action :set_match
    before_action :set_bet

    def destroy
      @bet.destroy
      redirect_to bets_admin_pool_match_path(@pool, @match), notice: "Aposta removida."
    end

    private

    def set_pool
      @pool = Pool.find(params[:pool_id])
    end

    def set_match
      @match = @pool.matches.find(params[:match_id])
    end

    def set_bet
      @bet = @match.bets.find(params[:id])
    end
  end
end
