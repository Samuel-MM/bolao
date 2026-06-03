module Admin
  class PoolsController < BaseController
    before_action :set_pool, only: [:show, :edit, :update, :destroy]

    def index
      @pools = Pool.includes(:creator).order(created_at: :desc)
    end

    def show
      @memberships = @pool.pool_memberships.includes(:user).order(created_at: :desc)
      @matches     = @pool.matches.order(:kickoff_at)
    end

    def new
      @pool = Pool.new
    end

    def create
      @pool = Pool.new(pool_params.merge(creator: current_user))
      if @pool.save
        redirect_to admin_pool_path(@pool), notice: "Bolão criado com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @pool.update(pool_params)
        redirect_to admin_pool_path(@pool), notice: "Bolão atualizado."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @pool.destroy
      redirect_to admin_pools_path, notice: "Bolão removido."
    end

    private

    def set_pool
      @pool = Pool.find(params[:id])
    end

    def pool_params
      params.require(:pool).permit(:name, :description, :min_bet_amount, :status)
    end
  end
end
