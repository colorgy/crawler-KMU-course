require 'crawler_rocks'
require 'pry'
require 'iconv'
require 'json'

class KmuCourseCrawler
	def initialize year: nil, term: nil, update_progress: nil, after_each: nil
		#@post_url = "https://wac.kmu.edu.tw/qur/qurq0006.php"
		@year = year
    	@term = term
		@update_progress_proc = update_progress
        @after_each_proc = after_each
		@ic = Iconv.new('utf-8//translit//IGNORE', 'big5')
	end

	def courses
		@courses = []
		year = @year
		term = @term
		r = `curl "https://wac.kmu.edu.tw/qur/qurq0006.php" -H "Origin: https://wac.kmu.edu.tw" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: zh-TW,zh;q=0.8,en-US;q=0.6,en;q=0.4" -H "Upgrade-Insecure-Requests: 1" -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36" -H "Content-Type: application/x-www-form-urlencoded" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Cache-Control: max-age=0" -H "Referer: https://wac.kmu.edu.tw/qur/qurq0006.php" -H "Connection: keep-alive" --data "_CD_SYEAR=#{year-1911}&_CD_SEM=#{term}&_CD_DEPTNO=&_CD_GRADE="%"25&_CD_SEQNO=&_CD_CHINESECO=&_CD_TEA=&_CD_ROOMNO=&_CD_CSK=&_CD_CLWEEK=&_CD_OPENYN=Y&m_SQR_FD"%"5B"%"5D=SYEAR&m_SQR_FD"%"5B"%"5D=SEM&m_SQR_FD"%"5B"%"5D=SEQNO&m_SQR_FD"%"5B"%"5D=DEPTNO&m_SQR_FD"%"5B"%"5D=MASTER&m_SQR_FD"%"5B"%"5D=SECNAM&m_SQR_FD"%"5B"%"5D=ACADNO&m_SQR_FD"%"5B"%"5D=CONO&m_SQR_FD"%"5B"%"5D=OPENYN&m_SQR_FD"%"5B"%"5D=NETYN&m_SQR_FD"%"5B"%"5D=CHOOSEMAN&m_SQR_FD"%"5B"%"5D=GRADE&m_SQR_FD"%"5B"%"5D=CLASSCODE&m_SQR_FD"%"5B"%"5D=SECQTY&m_SQR_FD"%"5B"%"5D=CHINESECO&m_SQR_FD"%"5B"%"5D=SM&m_SQR_FD"%"5B"%"5D=CREDIT&m_SQR_FD"%"5B"%"5D=CSK&m_SQR_FD"%"5B"%"5D=TEAFNAM&m_SQR_FD"%"5B"%"5D=COKIND&m_SQR_FD"%"5B"%"5D=CLWEEK&m_SQR_FD"%"5B"%"5D=BCL&m_SQR_FD"%"5B"%"5D=ECL&m_SQR_FD"%"5B"%"5D=W0&m_SQR_FD"%"5B"%"5D=W1&m_SQR_FD"%"5B"%"5D=W2&m_SQR_FD"%"5B"%"5D=W3&m_SQR_FD"%"5B"%"5D=W4&m_SQR_FD"%"5B"%"5D=W5&m_SQR_FD"%"5B"%"5D=W6&m_SQR_FD"%"5B"%"5D=ROOMNO&m_SQR_FD"%"5B"%"5D=RMK&m_SQR_OD1=&m_SQR_OD2=&m_SQR_OD3=&m_SQR_OD4=&m_SQR_OD5=&m_Action="%"BF"%"E9"%"A5X"%"C2"%"B2"%"B3t"%"AA"%"ED&m_CurRec=0&m_UPDMode=0&m_InSearch=&m_SearchSQL=" --compressed`
		doc = Nokogiri::HTML(@ic.iconv(r))
		
		
		index = doc.css('tr')
		index[1..-1].each do |row|
			datas = row.css('td')

			course_days = []
			course_periods = []
			course_locations = []

			if(datas[22].text.to_i!=0)
				datas[22].text.to_i.upto(datas[23].text.to_i) do |periods|
					course_days << datas[21].text
					course_periods << periods
					course_locations << datas[31].text
				end
			end

			course = {
						name: "#{datas[15].text.strip}",
						year: @year,
						term: @term,
						code: "#{@year}-#{@term}-#{datas[8].text.strip}",
						department: "#{datas[4].text.strip}",
						credits: "#{datas[17].text.strip}",
						lecturer: "#{datas[19].text}",
						day_1: course_days[0],
						day_2: course_days[1],
						day_3: course_days[2],
						day_4: course_days[3],
						day_5: course_days[4],
						day_6: course_days[5],
						day_7: course_days[6],
						day_8: course_days[7],
					    day_9: course_days[8],
					    period_1: course_periods[0],
						period_2: course_periods[1],
						period_3: course_periods[2],
						period_4: course_periods[3],
						period_5: course_periods[4],
						period_6: course_periods[5],
						period_7: course_periods[6],
						period_8: course_periods[7],
						period_9: course_periods[8],
						location_1: course_locations[0],
						location_2: course_locations[1],
						location_3: course_locations[2],
						location_4: course_locations[3],
					    location_5: course_locations[4],
						location_6: course_locations[5],
						location_7: course_locations[6],
						location_8: course_locations[7],
						location_9: course_locations[8],
						}

				@after_each_proc.call(course: course) if @after_each_proc
				@courses << course

		end
		@courses
	end

end

cwl =  KmuCourseCrawler.new(year: 2015, term: 1)
File.write('courses.json', JSON.pretty_generate(cwl.courses))