# frozen_string_literal: true

class Models::FiiDividend < Models::Base
  self.table_name = "fii_dividends"

  def self.update_dividend_for(tracked_fii)
    dividends = DividendoCrawler::FIIDividends.fetch(tracked_fii.cnpj, tracked_fii.trading_code)

    inserts = dividends.map do |item|
      Hash[
        *(
          %i(trading_code payment_at rate related_to approved_at isin_code label ex_at remarks)
            .zip([tracked_fii.trading_code, *dividends(item)])
        ).flatten
      ]
    end

    last_approval = dividends.max { |i| Time.parse(i["approvedOn"]) }.fetch("approvedOn", nil)

    next_sync_at = (last_approval.present? ? Time.parse(last_approval) : tracked_fii.next_sync_at) + 1.month

    transaction do
      upsert_all(inserts, unique_by: %i(payment_at isin_code trading_code), on_duplicate: :update)
      tracked_fii.update!(next_sync_at:)
    end
  end

  def self.dividends(hash)
    [
      hash["paymentDate"],
      hash["rate"].gsub(".", "").gsub(",", "."),
      hash["relatedTo"],
      hash["approvedOn"],
      hash["isinCode"],
      hash["label"],
      hash["lastDatePrior"],
      hash["remarks"]
    ]
  end
end
