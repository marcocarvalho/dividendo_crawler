# frozen_string_literal: true

class DividendoCrawler::FIIDividends < DividendoCrawler::Base
  # {"cnpj":"11160521000122","identifierFund":"HGCR","typeFund":7}
  # def self.list(cnpj, identifier_fund)
  #   new.list(cnpj:, identifierFund: identifier_fund)
  # end

  def path
    "fundsProxy/fundsCall/GetListedSupplementFunds/"
  end

  def self.fetch_by_trading_code(trading_code)
    fii = DividendoCrawler::FIIDetail.fetch(trading_code)
    fetch(*fii["detailFund"].slice("cnpj", "acronym").values)
  end

  def self.fetch(cnpj, identifier_fund)
    fii = new
    fii.merge_params(identifierFund: identifier_fund, typeFund: 7)
    result = fii.fetch(cnpj)
    result.include?("cashDividends") ? result["cashDividends"] : []
  end

  def id_param_name
    "cnpj"
  end
end
