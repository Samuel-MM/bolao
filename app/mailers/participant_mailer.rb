class ParticipantMailer < ApplicationMailer
  def approved(membership)
    @membership = membership
    @user       = membership.user
    @pool       = membership.pool

    mail(to: @user.email, subject: "Você foi aprovado no #{@pool.name}!")
  end

  def rejected(membership)
    @membership = membership
    @user       = membership.user
    @pool       = membership.pool

    mail(to: @user.email, subject: "Solicitação não aprovada — #{@pool.name}")
  end
end
