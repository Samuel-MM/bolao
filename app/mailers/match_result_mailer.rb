class MatchResultMailer < ApplicationMailer
  def winner(bet, prize_amount)
    @bet          = bet
    @user         = bet.user
    @match        = bet.match
    @prize_amount = prize_amount

    mail(to: @user.email,
         subject: "🏆 Você acertou o placar! #{@match.home_team} #{@match.home_score}x#{@match.away_score} #{@match.away_team}")
  end

  def loser(bet)
    @bet   = bet
    @user  = bet.user
    @match = bet.match

    mail(to: @user.email,
         subject: "Resultado: #{@match.home_team} #{@match.home_score}x#{@match.away_score} #{@match.away_team}")
  end

  def no_winner(match, admin, total_prize)
    @match       = match
    @admin       = admin
    @total_prize = total_prize

    mail(to: @admin.email,
         subject: "[Admin] Sem vencedor — #{@match.home_team} x #{@match.away_team}")
  end
end
