# frozen_string_literal: true

class DividendoCrawler::CashDividends < DividendoCrawler::Base
  def self.list(trading_name)
    new.list(tradingName: trading_name.gsub(/\W/, ''))
  end

  def path
    "listedCompaniesProxy/CompanyCall/GetListedCashDividends/"
  end

  def format_item(item)
    item["valueCash"] = format_decimal(item["valueCash"])
    item["ratio"] = format_decimal(item["ratio"])
    item["closingPricePriorExDate"] = format_decimal(item["closingPricePriorExDate"])
    item["corporateActionPrice"] = format_decimal(item["corporateActionPrice"])
    item["quotedPerShares"] = format_decimal(item["quotedPerShares"])
    item["dateApproval"] = to_iso_date(item["dateApproval"])
    item["lastDatePriorEx"] = to_iso_date(item["lastDatePriorEx"])
    item["dateClosingPricePriorExDate"] = to_iso_date(item["dateClosingPricePriorExDate"])
    item
  end

  def allowed_keys
    return :all
  end
end
