# frozen_string_literal: true

class DividendoCrawler::Company < DividendoCrawler::Base
  def path
    "listedCompaniesProxy/CompanyCall/GetDetail/"
  end

  # "codeCVM":"25070"

  def allowed_keys
    %w(issuingCompany
       companyName
       cnpj
       industryClassification
       website
       code
       codeCVM
       lastDate
       otherCodes)
  end

  def id_param_name
    "codeCVM"
  end

  def self.fetch(code_cvm)
    new.fetch(code_cvm)
  end
end
