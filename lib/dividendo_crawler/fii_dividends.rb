# frozen_string_literal: true

class DividendoCrawler::FIIDividends < DividendoCrawler::Base
  # {"cnpj":"11160521000122","identifierFund":"HGCR","typeFund":7}
  def self.list(cnpj, identifier_fund)
    new.list(cnpj:, identifierFund: identifier_fund)
  end

  def path
    "fundsProxy/fundsCall/GetListedSupplementFunds/"
  end

  def result_collection_name
    "cashDividends"
  end

  def reparse?
    true
  end
end
