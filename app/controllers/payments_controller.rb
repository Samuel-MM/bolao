class PaymentsController < ApplicationController
  before_action :set_payment, only: [:show, :submit_proof, :request_refund, :view_proof]
  before_action :block_if_refund_requested, only: [:show, :submit_proof]

  def show; end

  def view_proof
    redirect_to s3_presigned_get_url(@payment.proof_url), allow_other_host: true
  rescue Aws::Errors::MissingCredentialsError, KeyError
    redirect_to payment_path(@payment), alert: "Não foi possível gerar o link de visualização."
  end

  def presigned_url
    require "aws-sdk-s3"

    s3 = build_s3_resource
    filename    = params[:filename].gsub(/[^A-Za-z0-9._-]/, "_")
    key         = "proofs/#{SecureRandom.uuid}/#{filename}"
    bucket_name = ENV.fetch("AWS_S3_BUCKET")
    obj         = s3.bucket(bucket_name).object(key)

    presigned = obj.presigned_url(:put, expires_in: 300, content_type: params[:content_type])

    render json: { presigned_url: presigned, s3_key: key }
  rescue Aws::Errors::MissingCredentialsError, KeyError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def submit_proof
    key = params[:proof_url].presence
    if key
      @payment.submit_proof!(key)
      User.admin.find_each { |admin| PaymentMailer.proof_submitted(@payment, admin).deliver_later }
      redirect_to payment_path(@payment), notice: "Comprovante enviado! Aguarde a confirmação."
    else
      redirect_to payment_path(@payment), alert: "Envie o arquivo antes de confirmar."
    end
  end

  def request_refund
    @payment.request_refund!
    PaymentMailer.refund_requested(@payment).deliver_later
    redirect_to root_path, notice: "Reembolso solicitado. Aguarde o processamento pelo administrador."
  rescue RuntimeError => e
    redirect_to root_path, alert: e.message
  end

  private

  def block_if_refund_requested
    if @payment.refund_requested?
      redirect_to root_path, alert: "Esta aposta possui um reembolso em andamento."
    end
  end

  def set_payment
    @payment = Payment.joins(bet: :user).find_by!(id: params[:id], users: { id: current_user.id })
    @bet     = @payment.bet
    @match   = @bet.match
    @pool    = @match.pool
  end

  def build_s3_resource
    require "aws-sdk-s3"
    Aws::S3::Resource.new(
      region:      ENV.fetch("AWS_REGION", "us-east-1"),
      credentials: Aws::Credentials.new(
        ENV.fetch("AWS_ACCESS_KEY_ID"),
        ENV.fetch("AWS_SECRET_ACCESS_KEY")
      )
    )
  end

  def s3_presigned_get_url(key)
    s3  = build_s3_resource
    obj = s3.bucket(ENV.fetch("AWS_S3_BUCKET")).object(key)
    obj.presigned_url(:get, expires_in: 900) # 15 minutos
  end
end
