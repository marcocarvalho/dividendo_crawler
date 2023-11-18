# frozen_string_literal: true

class Services::SaveToDatabase
  def self.call
    new.call
  end

  def call
    progressbar = ProgressBar.create(title: "Saving...", total: list.count, format: "%t: |%W| %E")

    list.sort.each do |file|
      json = JSON.parse(File.read(file))
      Models::CashDividend.upsert_all_from_raw_data(json["cashDividends"])
      Models::StockDividend.upsert_all_from_raw_data(json["stockDividends"])
      progressbar.increment
      File.unlink(file)
    end
    %x{pg_dump -U root -F c b3 -f /Users/marcocarvalho/b3/data/$(date +%A |  tr '[:upper:]' '[:lower:]').pg.dump}
  end

  def list
    @list ||= Dir['lib/services/data/*.json'].to_a
  end
end