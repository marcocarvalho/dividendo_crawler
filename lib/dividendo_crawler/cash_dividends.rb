# frozen_string_literal: true

class DividendoCrawler::CashDividends < DividendoCrawler::Base
  def self.list(trading_name)
    new.list(tradingName: trading_name)
  end

  def path
    "listedCompaniesProxy/CompanyCall/GetListedCashDividends/"
  end

  def allowed_keys
    %w(
      typeStock
      dateApproval
      valueCash
      ratio
      corporateAction
      lastDatePriorEx
      dateClosingPricePriorExDate
      closingPricePriorExDate
      quotedPerShares
      corporateActionPrice
      lastDateTimePriorEx
    )
  end
end
