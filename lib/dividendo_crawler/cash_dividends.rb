# frozen_string_literal: true

class DividendoCrawler::CashDividends < DividendoCrawler::Base
  def self.list(trading_name: nil, ticker: nil)
    if (trading_name.nil? && ticker.nil?) || ( !trading_name.nil? && !ticker.nil? )
      raise ArgumentError, "Must provide either trading_name or ticker but not both"
    end

    if !ticker.nil? && trading_name.nil?
      trading_name = company_information(ticker)["tradingName"]
    end

    new.list(tradingName: trading_name.gsub(/\W/, ''))
  end

  private_class_method def self.company_information(ticker)
    company = DividendoCrawler::Companies.list(ticker)

    if company.size == 1
      company.first
    else
      raise NotImplementedError, "Multiple companies found for ticker: #{ticker}"
    end
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
end
