class MatchResultJob < ApplicationJob
  queue_as :default

  def perform(match_id)
    match = Match.find(match_id)
    return unless match.finished?

    winning_bets = match.winning_bets
    total_prize  = match.total_prize

    if winning_bets.any?
      prize_per_winner = (total_prize / winning_bets.count).round(2)

      winning_bets.each do |bet|
        MatchResultMailer.winner(bet, prize_per_winner).deliver_later
      end

      loser_ids = match.bets.joins(:payment)
                       .where(payments: { status: "confirmed" })
                       .where.not(id: winning_bets.ids)
                       .pluck(:id)

      Bet.where(id: loser_ids).each do |bet|
        MatchResultMailer.loser(bet).deliver_later
      end
    else
      User.admin.find_each do |admin|
        MatchResultMailer.no_winner(match, admin, total_prize).deliver_later
      end
    end

    check_pool_finished(match.pool)
  end

  private

  def check_pool_finished(pool)
    all_finished = pool.matches.all? { |m| m.finished? || m.cancelled? }
    pool.update!(status: "finished") if all_finished
  end
end
