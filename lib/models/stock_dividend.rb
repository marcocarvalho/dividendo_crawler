# frozen_string_literal: true

class Models::StockDividend < Models::Base
  self.table_name = "stock_dividends"

  def self.upsert_all_from_raw_data(items)
    return if items.empty?

    all_items = items.map do |item|
      item.transform_keys { |key| underscore(key.to_s) }
          .slice(*%w(approved_on last_date_prior multiplier factor asset_issued trading_code type_stock related_to label remarks))
    end

    all_items = unique_itens(all_items)

    begin
      upsert_all(all_items, unique_by: %i(approved_on asset_issued trading_code related_to))
    rescue
      puts JSON.pretty_generate(all_items)
      raise
    end
  end

  def self.unique_itens(itens)
    itens.uniq { |item| item.slice(*%i(approved_on asset_issued trading_code related_to)).values.join("") }
  end
end

__END__

[
  {
    "assetIssued": "BRALUPACNOR8",
    "factor": 4.0,
    "approvedOn": "2023-04-17",
    "isinCode": "BRALUPACNOR8",
    "label": "BONIFICACAO",
    "lastDatePrior": "2023-04-17",
    "remarks": "",
    "trading_code": "ALUP3",
    "typeStock": "ON",
    "multiplier": 1.04
  },
  {
    "assetIssued": "BRALUPACNPR5",
    "factor": 4.0,
    "approvedOn": "2023-04-17",
    "isinCode": "BRALUPACNPR5",
    "label": "BONIFICACAO",
    "lastDatePrior": "2023-04-17",
    "remarks": "",
    "trading_code": "ALUP4",
    "typeStock": "PN",
    "multiplier": 1.04
  },
  {
    "assetIssued": "BRALUPCDAM15",
    "factor": 4.0,
    "approvedOn": "2023-04-17",
    "isinCode": "BRALUPCDAM15",
    "label": "BONIFICACAO",
    "lastDatePrior": "2023-04-17",
    "remarks": "",
    "trading_code": "ALUP",
    "typeStock": "",
    "multiplier": 1.04
  }
]