class Services::FutureCashDividend
  attr_accessor :ticker, :date

  def initialize(ticker, today = Date.today.iso8601)
    @ticker = ticker
    @date = Date.parse(today)
  end

  def call
    DividendoCrawler::CashDividends
    .list(trading_name)
    .select { |i|  i["typeStock"] == type_stock && Date.parse(i["lastDatePriorEx"]) >= date }
    .sort_by { |i| Date.parse(i["lastDatePriorEx"]) }
  end

  def trading_name
    company_information["tradingName"]
  end

  def company_information
    @company_information ||= begin
      x = DividendoCrawler::Companies.list(ticker)
      if x.size == 1
        x.first
      else
        raise NotImplementedError, "Multiple companies found for ticker: #{ticker}"
      end
    end
  end

  def self.idiv_future_dividends(date = Date.today.iso8601)
    idiv_companies.each_with_object({}) do |ticker, obj|
      obj[ticker] = new(ticker, date).call
      obj
    end.select { |_, v| v.present? }
  end

  def type_stock
    @type_stock ||=
      case ticker.match(/\d+/).to_a.first
      when "3"
        "ON"
      when "4"
        "PN"
      when "5"
        "PNA"
      when "6"
        "PNB"
      when "11"
        "UNT"
      else
        warn "Unknown type for ticker: #{ticker}"
      end
  end

  def self.idiv_companies
    %w(
      ABCB4 AGRO3 ALUP11 AURE3 B3SA3 BBAS3 BBSE3 BEEF3 BRAP4 BRSR6 CMIG3 CMIG4 CMIN3
      CPFE3 CPLE3 CPLE6 CSMG3 CSNA3 CXSE3 DIRR3 EGIE3 FESA4 FLRY3 GGBR4 GOAU3 GOAU4
      GRND3 ITSA4 JBSS3 JHSF3 KEPL3 KLBN11 KLBN4 LAVV3 LEVE3 MRFG3 PETR3 PETR4 PSSA3
      RANI3 RAPT4 ROMI3 SANB11 SAPR4 TAEE11 TASA4 TGMA3 TRIS3 TRPL4 UNIP6 USIM5 VALE3
      VIVT3 WIZC3
    )
  end
end