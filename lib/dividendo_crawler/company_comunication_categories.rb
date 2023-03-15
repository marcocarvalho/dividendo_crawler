# frozen_string_literal: true

class DividendoCrawler::CompanyComunicationCategories < DividendoCrawler::Base
  def path
    "listedCompaniesProxy/CompanyCall/GetListCategories/"
  end

  # {"codeCVM":"12653","year":2023,"dateInitial":"2023-01-01","dateFinal":"2023-12-31","category":"","pageNumber":1,"pageSize":5}
  def self.list(code_cvm:, start_at:, end_at:, category: "")
    year = Date.parse(start_at).year
    new.list(codeCVM: code_cvm, year: year.to_s, dateInitial: start_at, dateFinal: end_at, category: category, pageSize: 50)
  end

  def reparse?
    true
  end

  # root
  def result_collection_name
    nil
  end
end
