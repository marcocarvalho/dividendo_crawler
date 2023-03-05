# frozen_string_literal: true

class DividendoCrawler::StructuredReports < DividendoCrawler::Base
  def self.list(code_cvm, year)
    new.list(codeCVM: code_cvm, year: year)
  end
  #eyJjb2RlQ1ZNIjoiNjE3MyIsImxhbmd1YWdlIjoicHQtYnIiLCJzdGF0dXMiOnRydWUsInllYXIiOiIyMDIyIn0=
  #https://sistemaswebb3-listados.b3.com.br/
  def path
    "listedCompaniesProxy/CompanyCall/GetListStructuredReports/"
  end

  def base_params
    { "status": true }
  end

  def allowed_keys
    return :all
    # %w(
    #   typeStock
    #   dateApproval
    #   valueCash
    #   ratio
    #   corporateAction
    #   lastDatePriorEx
    #   dateClosingPricePriorExDate
    #   closingPricePriorExDate
    #   quotedPerShares
    #   corporateActionPrice
    #   lastDateTimePriorEx
    # )
  end
end
