class PaymentMailer < ApplicationMailer
  def confirmed(payment)
    @payment = payment
    @user    = payment.user
    @bet     = payment.bet
    @match   = @bet.match

    mail(to: @user.email, subject: "Pagamento confirmado — #{@match.home_team} x #{@match.away_team}")
  end

  def proof_submitted(payment, admin)
    @payment = payment
    @admin   = admin
    @user    = payment.user
    @match   = payment.match
    @bet     = payment.bet

    mail(to: @admin.email, subject: "Comprovante enviado por #{@user.name}")
  end

  def rejected(payment)
    @payment = payment
    @user    = payment.user
    @bet     = payment.bet
    @match   = payment.match

    mail(to: @user.email, subject: "Comprovante não aprovado — #{@match.home_team} x #{@match.away_team}")
  end

  def refund_requested(payment)
    @payment = payment
    @user    = payment.user
    @match   = payment.match

    User.admin.find_each do |admin|
      mail(to: admin.email, subject: "Reembolso solicitado por #{@user.name}")
    end
  end

  def refund_processed(payment)
    @payment = payment
    @user    = payment.user
    @match   = payment.match

    mail(to: @user.email, subject: "Seu reembolso foi processado")
  end
end
