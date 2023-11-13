class Services::DividendToCSV
  attr_accessor :data

  def initialize(hash_data)
    @data = hash_data
  end

  def call
    CSV.generate(headers: true, force_quotes: true) do |csv|
      csv << headers.map(&:underscore)
      data.each do |ticker, dividends|
        dividends.each do |fields|
          csv << [ticker] + values(fields)
        end
      end
    end
  end

  def values(fields)
    fields.values_at(*headers[1..-1]).map { |num| num.is_a?(Numeric) ? num.to_s.gsub(".", ",") : num }
  end

  def headers
    %w(
      ticker
      typeStock
      lastDatePrior
      approvedOn
      paymentDate
      rate
      label
      relatedTo
    )
  end
end