# frozen_string_literal: true

RSpec.describe DividendoCrawler::RadCVM do
  describe "class methods" do
    subject(:klass) { described_class }

    let(:material) do
      {
        "company" => { "codeCVM" => "007617", "companyName" => "ITAUSA S.A.", "tradingName" => "ITAUSA" },
        "dateReference" => "12/2022",
        "delivery" => "Apresentação",
        "deliveryDate" => "10/01/2023 18:05:33",
        "status" => "Ativo",
        "category" => "Valores Mobiliários Negociados e Detidos",
        "type" => "Posição Individual - Cia, Controladas e Coligadas",
        "kind" => " ",
        "version" => "1",
        "subject" => "",
        "dateCancel" => "",
        "publishLocations" => [],
        "urlSearch" => "https://www.rad.cvm.gov.br/ENET/frmExibirArquivoIPEExterno.aspx?ID=1048629",
        "urlDownload" => "https://www.rad.cvm.gov.br/ENET/frmDownloadDocumento.aspx?Tela=ext&numSequencia=573359&numVersao=1&numProtocolo=1048629&descTipo=IPE&CodigoInstituicao=1",
        "deliveryDateTime" => "2023-01-10T18:05:33",
        "dateTimeReference" => "0001-01-01T00:00:00",
        "tradingName" => "ITAUSA S.A."
      }
    end

    it "creates a filename from material" do
      expect(klass.file_name_from_material(material)).to eq("2023-01-10-573359-1048629-v1-007617-itausa.pdf")
    end
  end
end
