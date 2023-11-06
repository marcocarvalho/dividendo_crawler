class Services::FutureCashDividend
  attr_accessor :ticker, :date

  def initialize(ticker, today = Date.today.iso8601, cache: true)
    @ticker = ticker.upcase
    @date = Date.parse(today)
    @cache = cache
  end

  def call
    load_ticker["cashDividends"]
    .select { |i| i["typeStock"] == type_stock && Date.parse(i["lastDatePrior"]) >= date }
    .sort_by { |i| Date.parse(i["lastDatePrior"]) }
  end

  def sum(field: "cashDividends", year:)
    date_range = Date.parse("#{year}-01-01")..Date.parse("#{year}-12-31")
    load_ticker[field]
      .select { |i| i["typeStock"] == type_stock && date_range.cover?(Date.parse(i["lastDatePrior"])) }
      .sum { |i| i["rate"] }
  end

  def cache?
    @cache
  end

  def load_ticker
    if cache? && File.exist?(filename)
      JSON.parse(File.read(filename))
    else
      FileUtils.mkdir_p(base_dir)
      load_and_save_ticker_data
    end
  end

  def load_and_save_ticker_data
    data = DividendoCrawler::Suplementary.fetch(ticker)
    File.open(filename, "w+") do |file|
      file.write(JSON.pretty_generate(data))
    end
    data
  end

  def base_dir
    File.join(File.expand_path(File.dirname(__FILE__), "../../.."), "data")
  end

  def filename
    @filename ||= File.join(base_dir, "#{date.iso8601}-#{ticker}.json")
  end

  def self.idiv_future_dividends(date = Date.today.iso8601, format: :json, progress: false)
    raise ArgumentError, "Acceptable formats are: json, csv" unless %i(csv json).include?(format)

    progressbar = ProgressBar.create(title: "fetching", total: companies_list.count, format: "%t: |%W| %E") if progress

    all_div = companies_list.each_with_object({}) do |ticker, obj|
      future_cash = new(ticker, date)
      obj[ticker] = future_cash.call
      obj
      progressbar.increment if progress
      sleep 1 unless future_cash.cache? # prevent throttling, it will take forever to finish, but :shrug:
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
      file.write(JSON.pretty_generate(DividendoCrawler::IndexComposition.compile_tickers(%w(ibov idiv IBXX IBRA))))
    end
  end

  def self.companies_list_filename
    File.join(File.dirname(File.expand_path(__FILE__)), "companies.json")
  end
end