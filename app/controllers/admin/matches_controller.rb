module Admin
  class MatchesController < BaseController
    before_action :set_pool
    before_action :set_match, only: [:edit, :update, :destroy, :sync_result, :bets]

    def index
      @matches = @pool.matches.order(:kickoff_at)
    end

    def lookup
      id = params[:id].to_i
      return render json: { error: "ID inválido" }, status: :bad_request unless id > 0

      data = FootballDataService.new.match(id)
      return render json: { error: "Jogo não encontrado na API" }, status: :not_found unless data

      render json: {
        home_team:  data.dig("homeTeam", "name"),
        away_team:  data.dig("awayTeam", "name"),
        kickoff_at: data["utcDate"],
        home_crest: data.dig("homeTeam", "crest"),
        away_crest: data.dig("awayTeam", "crest")
      }
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
      was_finished = @match.finished?
      if @match.update(match_params)
        MatchResultJob.perform_later(@match.id) if @match.finished? && !was_finished
        redirect_to admin_pool_matches_path(@pool), notice: "Jogo atualizado."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def bets
      @bets = @match.bets
                    .includes(:user, :payment)
                    .order(created_at: :asc)
      @winning_ids = @match.finished? ? @match.winning_bets.ids : []
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
                                    :status, :home_score, :away_score, :bonus_prize,
                                    :home_crest, :away_crest)
    end
  end
end
