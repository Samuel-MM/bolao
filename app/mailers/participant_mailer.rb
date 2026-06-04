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

  def membership_requested(membership, admin)
    @membership = membership
    @user       = membership.user
    @pool       = membership.pool
    @admin      = admin

    mail(to: @admin.email, subject: "Nova solicitação de entrada — #{@pool.name}")
  end
end
