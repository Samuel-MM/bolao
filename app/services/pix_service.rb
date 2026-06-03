class PixService
  PAYLOAD_FORMAT_INDICATOR = "000201"
  MERCHANT_CATEGORY_CODE   = "52040000"
  TRANSACTION_CURRENCY     = "5303986"
  COUNTRY_CODE             = "5802BR"

  def initialize(key:, name:, city:, amount:, txid:)
    @key    = key
    @name   = name.gsub(/[^A-Za-z0-9 ]/, "")[0..24]
    @city   = city.gsub(/[^A-Za-z0-9 ]/, "")[0..14]
    @amount = format("%.2f", amount)
    @txid   = txid[0..24]
  end

  def generate_code
    payload = build_payload
    payload + "6304" + crc16(payload + "6304")
  end

  def generate_qr_svg
    qr = RQRCode::QRCode.new(generate_code)
    qr.as_svg(
      offset: 0,
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 4,
      standalone: true
    )
  end

  private

  def build_payload
    merchant_account = tlv("00", "br.gov.bcb.pix") + tlv("01", @key)
    additional_data  = tlv("05", @txid)

    PAYLOAD_FORMAT_INDICATOR +
      tlv("26", merchant_account) +
      MERCHANT_CATEGORY_CODE +
      TRANSACTION_CURRENCY +
      tlv("54", @amount) +
      COUNTRY_CODE +
      tlv("59", @name) +
      tlv("60", @city) +
      tlv("62", additional_data)
  end

  def tlv(id, value)
    id + format("%02d", value.length) + value
  end

  def crc16(str)
    crc = 0xFFFF
    str.each_char do |c|
      crc ^= c.ord << 8
      8.times do
        crc = (crc & 0x8000) != 0 ? ((crc << 1) ^ 0x1021) : (crc << 1)
        crc &= 0xFFFF
      end
    end
    format("%04X", crc)
  end
end
