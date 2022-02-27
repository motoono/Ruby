require "bundler/setup"
require 'open-uri'
require "selenium-webdriver"
require "csv"
require "pry-byebug"
require "nokogiri"
require "open_uri_redirections"

bom = %w(EF BB BF).map { |e| e.hex.chr }.join
csv_file = CSV.generate(bom) do |csv|
  csv << ["URL"]
end

File.open("vg_url.csv", "w") do |file|
  file.write(csv_file)
end

driver = Selenium::WebDriver.for :chrome # ブラウザの起動

#binding.pry
driver.navigate.to("https://cf-vanguard.com/cardlist/cardsearch/?expansion=225")
sleep(3)
15.times do
driver.execute_script('window.scrollTo(0, document.body.scrollHeight)') 
sleep(3)
end


begin
  driver.find_elements(:css , "#cardlist-container > ul > li").each do |cards|
    begin
      all_url = []
      #binding.pry
      vg_url = cards.find_element(:css, "a").attribute('href')

      all_vg_url =  vg_url

      all_url << all_vg_url
      p all_url
      CSV.open("vg_url.csv", "a") do |file|
        file << all_url
      end
      rescue => e
        p "error"
      CSV.open("vg_url.csv", "a") do |file|
        file << ["error"]
      end
    end
  end
  rescue => e
end

bom = %w(EF BB BF).map { |e| e.hex.chr }.join
csv_file = CSV.generate(bom) do |csv|
  
end

File.open("newvg_result.csv", "w") do |file|
  file.write(csv_file)
end

  def get_parsed_html(url)
    html = URI.open(url) do |f|
      charset = f.charset
      f.read
    end

    Nokogiri::HTML.parse(html,nil,'utf-8')
  end

  path = "./vg_url.csv"
  url_array = Array.new
  
  CSV.foreach(path, headers: true) do |row|
    url_array << row[0]
  end
  
url_array.each do |url|
  #begin
  doc = get_parsed_html(url)
  
  doc.css('#site > div.site-main > div > div > div._entry-content > div > div > div.cardlist_detail').each do |total| 
    random = Random.new
    sleep(random.rand(1..3)) #1〜3秒待つ
    #binding.pry
    
    name = total.css('div.data > div.name > span.face').text.gsub(" ", "")
    sub_name = total.css('div.data > div.name > span.ruby').text[/（(.*?)）/, 1].gsub(" ", "")
    nation = total.css('div.data > div > div.nation').text.gsub('-','その他')
    group = total.css('').text.gsub('-','その他')
    number = total.css('div.data > div > div.number').text
    rarity = total.css('div.data > div> div.rarity').text
    efc = total.css('div.data > div.effect').text
    img = 'https://cf-vanguard.com' + total.css('div.image > div > img').attribute('src').value
    img_name = 'rush' + number.gsub('/','') + '.jpg'
    vgcards = []
    vgcards << name
    vgcards << sub_name
    vgcards << nation
    vgcards << number
    vgcards << rarity
    vgcards << efc
    vgcards << img_name
    vgcards << group
    p vgcards
    
    filename = "./lib/img/#{img_name}"
    #ファイルを書き込み
    open(filename, 'wb') do |file|
      URI.open(img) do |data|
        file.write(data.read)
        p filename
      end
    end


    CSV.open("newvg_result.csv", "a") do |file|
      file << vgcards
    end
  rescue => e
    p "error"
    CSV.open("newvg_result.csv", "a") do |file|
      file << ["error"]
    end
  end
end