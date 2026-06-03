require "test_helper"

class PaymentTest < ActiveSupport::TestCase
  def setup
    @admin = create_admin
    @pool  = create_pool(creator: @admin)
    @user  = create_user
    create_approved_membership(pool: @pool, user: @user)
    @match   = create_match(pool: @pool, kickoff_at: 2.hours.from_now)
    @bet     = create_bet(match: @match, user: @user)
    @payment = @bet.payment
  end

  test "payment is created with pending status" do
    assert @payment.pending?
  end

  test "payment amount equals pool min_bet_amount" do
    assert_equal @pool.min_bet_amount, @payment.amount
  end

  test "confirm! sets status to confirmed and timestamps" do
    @payment.confirm!
    assert @payment.confirmed?
    assert @payment.paid_at.present?
    assert @payment.approved_at.present?
  end

  test "reject! sets status to rejected" do
    @payment.reject!
    assert @payment.rejected?
  end

  test "submit_proof! saves URL and changes status to submitted" do
    @payment.submit_proof!("https://s3.example.com/proof.jpg")
    assert @payment.submitted?
    assert_equal "https://s3.example.com/proof.jpg", @payment.proof_url
  end

  test "request_refund! sets refund_requested_at" do
    @payment.request_refund!
    assert @payment.refund_requested_at.present?
    assert @payment.refund_requested?
  end

  test "request_refund! raises when match already started" do
    @match.update_column(:kickoff_at, 1.hour.ago)
    assert_raises(RuntimeError) { @payment.request_refund! }
  end

  test "process_refund! sets status to refunded" do
    @payment.request_refund!
    @payment.process_refund!
    assert @payment.refunded?
    assert @payment.refund_processed_at.present?
  end
end
