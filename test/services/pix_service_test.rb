require "test_helper"

class PixServiceTest < ActiveSupport::TestCase
  def setup
    @service = PixService.new(
      key: "+5511999999999",
      name: "Bolao da Copa",
      city: "Sao Paulo",
      amount: 20.0,
      txid: "BET123"
    )
  end

  test "generates a non-blank PIX code" do
    code = @service.generate_code
    assert code.present?
  end

  test "PIX code starts with payload format indicator" do
    assert @service.generate_code.start_with?("000201")
  end

  test "PIX code ends with 4-char CRC hex checksum" do
    code = @service.generate_code
    crc = code[-4..]
    assert_match(/\A[0-9A-F]{4}\z/, crc)
  end

  test "PIX code contains pix GUI" do
    assert_includes @service.generate_code, "br.gov.bcb.pix"
  end

  test "generates QR code SVG" do
    svg = @service.generate_qr_svg
    assert svg.include?("<svg")
  end

  test "same inputs always produce same code" do
    assert_equal @service.generate_code, @service.generate_code
  end
end
