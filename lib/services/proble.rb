class Services::Probe
  attr_accessor :filename, :year

  def initialize(filename, year)
    @filename = filename
    @year = year
  end

  def call
    assets = {}

    data.each do |row|
      asset = assets[row["ticker"]] ||= Asset.new
      asset.add(row)
    end

    puts "Ticker;Quantity;Dividends;Avg Price;Discounted Avg Price;Net Profit"
    assets.each do |_, asset|
      puts asset.to_s
    end
  end

  def data
    @data ||= CSV.read(filename, headers: true).map(&:to_h).sort_by { |row| Date.parse(row['last_date_prior_ex']) }
  end

  class Asset
    attr_accessor :ticker, :quantity, :dividends, :total_invested

    def initialize
      @quantity = 0
      @dividends = 0
      @total_invested = 0
    end

    def add(row)
      raise "Cannot modify the ticker after it was set" if row["ticker"] != ticker && ticker != nil

      @ticker = row["ticker"]

      value_cash = row["value_cash"].gsub(",", ".").to_f
      closing_price_prior_ex_date = row["closing_price_prior_ex_date"].gsub(",", ".").to_f

      new_dividends = value_cash * quantity

      buy_quantity = discounted_avg_price.zero? ? 1 : ((new_dividends) / (total_invested - dividends)).ceil

      @dividends += new_dividends
      @quantity += buy_quantity
      @total_invested += buy_quantity * closing_price_prior_ex_date
    end

    def avg_price
      quantity == 0 ? 0 : (total_invested / quantity)
    end

    def discounted_avg_price
      quantity == 0 ? 0 : ((total_invested - dividends) / quantity)
    end

    def net_profit
      total_invested == 0 ? 0 : (dividends / total_invested)
    end

    def to_s
      "#{ticker};#{d(quantity)};#{d(dividends)};#{d(avg_price)};#{d(discounted_avg_price)};#{d(net_profit)}"
    end

    def d(val)
      val.round(2).to_s.gsub(".", ",")
    end
  end
end

__END__

{"ticker"=>"ITUB3",
  "type_stock"=>"ON",
  "date_approval"=>"2022-12-09",
  "value_cash"=>"0,01765",
  "ratio"=>"1,0",
  "corporate_action"=>"JRS CAP PROPRIO",
  "last_date_prior_ex"=>"2023-09-29",
  "date_closing_price_prior_ex_date"=>"2023-09-29",
  "closing_price_prior_ex_date"=>"23,06",
  "quoted_per_shares"=>"1,0",
  "corporate_action_price"=>"0,076539",
  "last_date_time_prior_ex"=>"2023-09-29T00:00:00"}],