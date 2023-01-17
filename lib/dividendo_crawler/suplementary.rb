# frozen_string_literal: true

class DividendoCrawler::Suplementary < DividendoCrawler::Base
  def path
    "listedCompaniesProxy/CompanyCall/GetListedSupplementCompany/"
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
    "issuingCompany"
  end

  def self.fetch(_trading)
    new.fetch(code_cvm)
  end
end
