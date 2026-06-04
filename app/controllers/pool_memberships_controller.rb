class PoolMembershipsController < ApplicationController
  def create
    @pool = Pool.find_by!(invite_token: params[:invite_token])

    membership = @pool.pool_memberships.find_or_initialize_by(user: current_user)

    if membership.persisted?
      redirect_to pool_invite_path(@pool.invite_token),
                  alert: "Você já solicitou entrada neste bolão (status: #{membership.status})."
      return
    end

    if membership.save
      User.admin.find_each { |admin| ParticipantMailer.membership_requested(membership, admin).deliver_later }
      redirect_to root_path,
                  notice: "Solicitação enviada! Aguarde a aprovação do administrador."
    else
      redirect_to pool_invite_path(@pool.invite_token),
                  alert: "Não foi possível enviar a solicitação."
    end
  end
end
