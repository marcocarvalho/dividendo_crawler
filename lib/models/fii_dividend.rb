# frozen_string_literal: true

class Models::FiiDividend < Models::Base
  self.table_name = "fii_dividends"

  def self.update_dividend_for(tracked_fii)
    dividends = DividendoCrawler::FIIDividends.fetch(tracked_fii.cnpj, tracked_fii.trading_code)

    inserts = dividends.map do |item|
      tmp = db_time(item["approvedOn"]) + 1.month
      tracked_fii.next_sync_at = tmp if tracked_fii.next_sync_at < tmp

      Hash[
        *(
          %i(trading_code payment_at rate related_to approved_at isin_code label ex_at remarks)
            .zip([tracked_fii.trading_code, *dividends(item)])
        ).flatten
      ]
    end

    transaction do
      upsert_all(inserts, unique_by: %i(payment_at isin_code trading_code), on_duplicate: :update)
      tracked_fii.save!
    end
  end

  def self.db_time(dt)
    Time.parse(dt.split("/").reverse.join("-"))
  end

  def self.dividends(hash)
    [
      db_time(hash["paymentDate"]),
      hash["rate"].gsub(".", "").gsub(",", "."),
      hash["relatedTo"],
      db_time(hash["approvedOn"]),
      hash["isinCode"],
      hash["label"],
      db_time(hash["lastDatePrior"]),
      hash["remarks"]
    ]
  end
end
