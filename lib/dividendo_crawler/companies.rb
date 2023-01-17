# frozen_string_literal: true

class DividendoCrawler::Companies < DividendoCrawler::Base
  def governances
    {
      NM: { governance: "18" },
      N2: { governance: "17" },
      N1: { governance: "16" },
      DRE: { governance: "1" },
      MA: { governance: "24" }, # Bovespa Mais
      M2: { governance: "25" }, # Bovespa Mais Nivel 2
      MB: { governance: "7" }, # Balcao organizado
      incentivadas: { governance: "915" },
      blank: { governance: "916" }
    }
  end

  def path
    "listedCompaniesProxy/CompanyCall/GetInitialCompanies/"
  end

  def self.reduced_list(filter = {})
    list.filter { |i| !["DRE", ""].include?(i["market"]) }
  end

  def allowed_keys
    %w(codeCVM issuingCompany companyName segment market tradingName)
  end
end

# https://sistemaswebb3-listados.b3.com.br/listedCompaniesProxy/CompanyCall/GetInitialCompanies/eyJsYW5ndWFnZSI6InB0LWJyIiwicGFnZU51bWJlciI6MSwicGFnZVNpemUiOjIwLCJnb3Zlcm5hbmNlIjoiMTcifQ==
