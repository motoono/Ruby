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

File.open("dm_url.csv", "w") do |file|
  file.write(csv_file)
end

driver = Selenium::WebDriver.for :chrome # ブラウザの起動

#binding.pry
driver.navigate.to("https://dm.takaratomy.co.jp/card/")
sleep(3)
driver.find_element(:css, "#search_cond > div.searchList01_term01 > div:nth-child(3) > select > option:nth-child(2)").click
sleep(3)
driver.find_element(:css, "#search_cond > div.searchSubmit01 > input.submitBtn01").click
sleep(5)

page = -1
begin
  loop do
    driver.find_elements(:css , "#cardlist > ul > li").each do |cards|
      begin
        all_url = []
        #binding.pry
        dm_url = cards.find_element(:css, "a").attribute('data-href')

        all_dm_url = "https://dm.takaratomy.co.jp" + dm_url

        all_url << all_dm_url
        p all_url
        CSV.open("dm_url.csv", "a") do |file|
          file << all_url
        end
        rescue => e
          p "error"
        CSV.open("dm_url.csv", "a") do |file|
          file << ["error"]
        end
      end
    end
    page += 1
    #binding.pry
    all_page = driver.find_elements(:css,"#cardlist > div > div > a")[page].click
    sleep(30)
  rescue => e
    break
  end
end

bom = %w(EF BB BF).map { |e| e.hex.chr }.join
csv_file = CSV.generate(bom) do |csv|
  
end

File.open("newdm_result.csv", "w") do |file|
  file.write(csv_file)
end

  def get_parsed_html(url)
    html = URI.open(url) do |f|
      charset = f.charset
      f.read
    end

    Nokogiri::HTML.parse(html,nil,'utf-8')
  end

  path = "dm_url.csv"
  url_array = Array.new
  
  CSV.foreach(path, headers: true) do |row|
    url_array << row[0]
  end
  
url_array.each do |url|
  #begin
  doc = get_parsed_html(url)
  
  doc.css('#mainContent > section').each do |total| 
    random = Random.new
    sleep(random.rand(1..3)) #1〜3秒待つ
    #binding.pry
    #tt = name.text.gsub(/\n|\t/,'')
    #img = total.css('a > img').attribute('src').value
    #name = total.css('table > tr.windowtitle > th').text.gsub(/\(.+?\)/, "/").chop

  
    name = total.css('table > tr.windowtitle > th').text.gsub(/\(.+?\)/, "/").chop.split('/').uniq.join('/')
    number = total.css('table > tr.windowtitle > th').text.scan(/\(.+?\)/).join.gsub(' ','').gsub('DM','').scan(/(?<=\().*?(?=\))/).join
    color = total.css('table > tr:nth-child(2) > td.civtxt').text.chars.uniq.join
    rarity = total.css('table > tr:nth-child(3) > td.raretxt').text.chars.uniq.join
    efc = total.css('table > tr:nth-child(7) > td').text
    cost = total.css('table > tr:nth-child(4) > td.costtxt').text.gsub("マナ","").delete(' ')
    type = total.css('table > tr:nth-child(2) > td.typetxt').text
    img = "https://dm.takaratomy.co.jp/" + total.css('table > tr:nth-child(2) > td.cardarea > div > img').attribute('src').value
    img_name = 'rush' + total.css('table > tr.windowtitle > th').text[/\((.*?)\)/, 1].gsub(' ','').gsub('DM','').gsub('/','') + '.jpg'
    dmcards = []
    dmcards << name
    dmcards << number
    dmcards << color
    dmcards << rarity
    dmcards << efc
    dmcards << cost
    dmcards << type
    dmcards << img_name
    p dmcards
    
    filename = "./lib/img/#{img_name}"
    #ファイルを書き込み
    open(filename, 'wb') do |file|
      URI.open(img) do |data|
        file.write(data.read)
        p filename
      end
    end

    CSV.open("newdm_result.csv", "a") do |file|
      file << dmcards
    end
  rescue => e
    p "error"
    CSV.open("newdm_result.csv", "a") do |file|
      file << ["error"]
    end
  end
end