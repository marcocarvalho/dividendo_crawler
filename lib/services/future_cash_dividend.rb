class Services::FutureCashDividend
  attr_accessor :ticker, :date

  def initialize(ticker, today = Date.today.iso8601)
    @ticker = ticker
    @date = Date.parse(today)
  end

  def call
    DividendoCrawler::CashDividends
    .list(ticker:)
    .select { |i|  i["typeStock"] == type_stock && Date.parse(i["lastDatePriorEx"]) >= date }
    .sort_by { |i| Date.parse(i["lastDatePriorEx"]) }
  end

  def self.idiv_future_dividends(date = Date.today.iso8601, format: :json)
    raise ArgumentError, "Acceptable formats are: json, csv" unless %i(csv json).include?(format)

    all_div = companies_list.each_with_object({}) do |ticker, obj|
      obj[ticker] = new(ticker, date).call
      obj
    end.select { |_, v| v.present? }

    if format == :json
      all_div
    elsif format == :csv
      Services::DividendToCSV.new(all_div).call
    end
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

  def self.companies_list
    update_companies_list unless File.exist?(companies_list_filename)
    @companies_list ||= JSON.parse(File.read(companies_list_filename))
  end

  def self.update_companies_list
    File.open(companies_list_filename, "w+") do |file|
      file.write(DividendoCrawler::IndexComposition.compile_tickers(%w(ibov idiv IBXX IBRA)).to_json)
    end
  end

  def self.companies_list_filename
    File.join(File.dirname(File.expand_path(__FILE__)), "companies.json")
  end
end