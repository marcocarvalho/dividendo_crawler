# https://sistemaswebb3-listados.b3.com.br/indexProxy/indexCall/GetPortfolioDay/eyJsYW5ndWFnZSI6InB0LWJyIiwicGFnZU51bWJlciI6MSwicGFnZVNpemUiOjIwLCJpbmRleCI6IlNNTEwiLCJzZWdtZW50IjoiMSJ9
# {"language":"pt-br","pageNumber":1,"pageSize":20,"index":"SMLL","segment":"1"}

# frozen_string_literal: true

class DividendoCrawler::IndexComposition < DividendoCrawler::Base
  def path
    "indexProxy/indexCall/GetPortfolioDay/"
  end

  def self.list
    new.list(index: "SMLL", segment: "1")
  end

  def format_item(item)
    item["part"] = item["part"].gsub(",", ".").to_f
    item["theoricalQty"] = item["theoricalQty"].gsub(".", "").to_i
    item["type"] = item["type"].strip.gsub(/\s+/, " ")
    item
  end

  def allowed_keys
    %w(cod asset type part theoricalQty)
  end
end

# https://sistemaswebb3-listados.b3.com.br/listedCompaniesProxy/CompanyCall/GetInitialCompanies/eyJsYW5ndWFnZSI6InB0LWJyIiwicGFnZU51bWJlciI6MSwicGFnZVNpemUiOjIwLCJnb3Zlcm5hbmNlIjoiMTcifQ==

__END__

{
  "page": {
      "pageNumber": 1,
      "pageSize": 20,
      "totalRecords": 117,
      "totalPages": 6
  },
  "header": {
      "date": "20/09/23",
      "text": "Quantidade Teórica Total",
      "part": "100,000",
      "partAcum": null,
      "textReductor": "Redutor",
      "reductor": "132.218.330,75499324",
      "theoricalQty": "26.937.758.013"
  },
  "results": [
      {
          "segment": null,
          "cod": "RRRP3",
          "asset": "3R PETROLEUM",
          "type": "ON      NM",
          "part": "2,683",
          "partAcum": null,
          "theoricalQty": "235.661.666"
      },
      ...
 ]
}