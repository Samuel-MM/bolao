module Admin
  class PaymentsController < BaseController
    before_action :set_payment, only: [:show, :confirm, :reject, :process_refund, :view_proof]

    def index
      @submitted       = Payment.submitted.includes(bet: [:user, { match: :pool }]).order(created_at: :asc)
      @refund_requests = Payment.where.not(refund_requested_at: nil)
                                .where(refund_processed_at: nil)
                                .includes(bet: [:user, { match: :pool }])
                                .order(refund_requested_at: :asc)
    end

    def show; end

    def view_proof
      require "aws-sdk-s3"
      s3  = Aws::S3::Resource.new(
        region:      ENV.fetch("AWS_REGION", "us-east-1"),
        credentials: Aws::Credentials.new(
          ENV.fetch("AWS_ACCESS_KEY_ID"),
          ENV.fetch("AWS_SECRET_ACCESS_KEY")
        )
      )
      obj = s3.bucket(ENV.fetch("AWS_S3_BUCKET")).object(@payment.proof_url)
      redirect_to obj.presigned_url(:get, expires_in: 900), allow_other_host: true
    rescue Aws::Errors::MissingCredentialsError, KeyError
      redirect_to admin_payment_path(@payment), alert: "Não foi possível gerar o link do comprovante."
    end

    def confirm
      @payment.confirm!
      PaymentMailer.confirmed(@payment).deliver_later
      redirect_to admin_payments_path, notice: "Pagamento de #{@payment.user.name} confirmado."
    end

    def reject
      @payment.reject!(reason: params[:rejection_reason])
      PaymentMailer.rejected(@payment).deliver_later
      redirect_to admin_payments_path, notice: "Pagamento rejeitado e participante notificado."
    end

    def process_refund
      @payment.process_refund!
      PaymentMailer.refund_processed(@payment).deliver_later
      redirect_to admin_payments_path, notice: "Reembolso de #{@payment.user.name} processado."
    end

    private

    def set_payment
      @payment = Payment.includes(bet: [:user, { match: :pool }]).find(params[:id])
    end
  end
end
