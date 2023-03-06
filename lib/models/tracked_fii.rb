# frozen_string_literal: true

class Models::TrackedFii < Models::Base
  self.table_name = "tracked_fiis"

  def self.add_tracked_fii!(trading_code)
    details = DividendoCrawler::FIIDetail.fetch(trading_code)

    cnpj, trading_code = details["detailFund"].slice("cnpj", "tradingCode").values

    upsert({cnpj:, trading_code:, next_sync_at: Time.now}, unique_by: %i(cnpj trading_code))
  end
end
