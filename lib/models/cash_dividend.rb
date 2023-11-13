# frozen_string_literal: true

class Models::CashDividend < Models::Base
  self.table_name = "cash_dividends"

  def self.upsert_all_from_raw_data(items)
    return if items.empty?

    all_items = items.map do |item|
      item.transform_keys { |key| underscore(key.to_s) }
          .slice("asset_issued", "payment_date", "rate", "related_to", "approved_on", "label", "last_date_prior", "remarks", "trading_code", "type_stock")
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

[{
  "assetIssued": "BRAALRACNOR6",
  "paymentDate": "2020-12-18",
  "rate": 0.08729755405,
  "relatedTo": "ANUAL/2019",
  "approvedOn": "2020-04-27",
  "isinCode": "BRAALRACNOR6",
  "label": "DIVIDENDO",
  "lastDatePrior": "2020-04-27",
  "remarks": "",
  "trading_code": "AALR3",
  "typeStock": "ON"
}]
