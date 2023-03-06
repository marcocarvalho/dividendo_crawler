# frozen_string_literal: true

class Models::TrackedFii < Models::Base
  self.table_name = "tracked_fiis"

  scope :updatable, -> { where("next_sync_at < ?", Date.current) }

  def self.add_tracked_fii!(trading_code)
    details = DividendoCrawler::FIIDetail.fetch(trading_code)

    cnpj, trading_code = details["detailFund"].slice("cnpj", "tradingCode").values

    upsert({cnpj:, trading_code:, next_sync_at: Time.now}, unique_by: %i(cnpj trading_code))
  end

  def self.process
    updatable.find_each do |fii|
      Models::FiiDividend.update_dividend_for(fii)
    end
  end
end
