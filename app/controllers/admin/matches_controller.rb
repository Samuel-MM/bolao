module Admin
  class MatchesController < BaseController
    before_action :set_pool
    before_action :set_match, only: [:edit, :update, :destroy, :sync_result]

    def index
      @matches = @pool.matches.order(:kickoff_at)
    end

    def new
      @match = @pool.matches.build
    end

    def create
      @match = @pool.matches.build(match_params)
      if @match.save
        redirect_to admin_pool_matches_path(@pool), notice: "Jogo criado."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @match.update(match_params)
        redirect_to admin_pool_matches_path(@pool), notice: "Jogo atualizado."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @match.destroy
      redirect_to admin_pool_matches_path(@pool), notice: "Jogo removido."
    end

    def sync_result
      SyncMatchResultJob.perform_later(@match.id)
      redirect_to admin_pool_matches_path(@pool), notice: "Sincronização agendada."
    end

    private

    def set_pool
      @pool = Pool.find(params[:pool_id])
    end

    def set_match
      @match = @pool.matches.find(params[:id])
    end

    def match_params
      params.require(:match).permit(:home_team, :away_team, :kickoff_at, :api_football_id,
                                    :status, :home_score, :away_score)
    end
  end
end
