require "open-uri"
require "nokogiri"
require "time"

class	CakeTestRunner
	TESTCASE = Struct.new(:classname, :methodname, :time, :error_infos)
	ERRORINFO = Struct.new(:type, :description)

	@testcases
	@test_date

	def	initialize
		@testcases = Array.new
	end

	#
	#	指定されたURLへアクセスして結果を取得
	#
	def readHTTP(url)
		io = open(url)
		text = io.read
		return	text
	end
	private :readHTTP


	#
	#	指定されたURLのテストを実行
	#
	def	runTestByURL(url)
		result_text = readHTTP(url)
		date = Time.now
		retrieveResult(result_text, date) 
	end


	#
	#	テスト結果のテキストから必要な情報を取得する
	#
	def	retrieveResult(result_text, date)
		@test_date = convertDateTime(date)

		doc = Nokogiri::HTML(result_text)

		test_case = TESTCASE.new

		#<div  class="test-results"><h2>Individual test case: controllers/memos_controller.test.php</h2>
		doc.xpath("//div[@class='test-results']/h2").each do |node|
			#とりあえず、最初に見つけた1つのみを取得
			#実際は単体でテストを起動するので1つしか無い気がする
			test_case.classname = node.content
			test_case.methodname = "method"			#	仮のメソッド名を設定
			test_case.error_infos = Array.new

			@testcases << test_case
			break
		end

		#	エラーに関係したノードを取得
		doc.xpath("//li[@class='error' or @class='fail']//div[@class='msg']").each do |node|
			error_info = ERRORINFO.new()

			parent_node = node.parent()
			attr = "class"
			error_info.type = parent_node.get_attribute(attr)

			#	詳細情報？
			#	ノードの設定を表示してみたら「兄弟」ではなく「子供」だった…
			#	構造上、どうみても対象ノードの子供では無いような気がするのだが…
			next_node = node.next_element()

			error_info.description = node.content + "\n" + next_node.content

			test_case.error_infos << error_info
		end

	end

	#
	#	現在保持されている結果を出力
	#
	def	outputResult(filename)
		doc = Nokogiri::XML::Document.new
		doc.encoding = "utf-8"

		top_node = Nokogiri::XML::Node.new("testsuite", doc)
		top_node["errors"] = getErrorCount().to_s
		top_node["failures"] = getFailureCount().to_s
		top_node["tests"] = @testcases.length.to_s
		top_node["time"] = "0.056"
		top_node["timestamp"] = @test_date
		doc.add_child(top_node)

		@testcases.each do |testcase|
			if testcase.error_infos == nil

				node = Nokogiri::XML::Node.new("testcase", doc)
				names = testcase.classname.split(/\./)
				node["classname"] = names[0]
				node["name"]      = testcase.methodname
				#node["time"]      = testcase.time
				top_node.add_child(node)
			elsif
				
				testcase.error_infos.each do |error_info|
					node = Nokogiri::XML::Node.new("testcase", doc)
					names = testcase.classname.split(/\./)
					node["classname"] = names[0]
					node["name"]      = testcase.methodname
					#node["time"]      = testcase.time
					top_node.add_child(node)

					tag_name = getTagNameByType(error_info.type)
					error_node = Nokogiri::XML::Node.new(tag_name, doc)
					error_node["message"] = error_info.type
					error_node.content = error_info.description
					node.add_child(error_node)
				end
			end
		end

		io = File.open(filename, "w")
		doc.write_xml_to(io)
		io.close()
	end


	#
	#	日付を出力用に変換
	#
	def	convertDateTime(datetime)
		return	datetime.iso8601
	end


	#
	#	種類によって名前を
	#
	def	getTagNameByType(type_name)
		name_table = {"fail" => "failure", "error" => "error"}
		return	name_table[type_name]
	end


	#
	#	エラー、テスト失敗の数を取得
	#
	def	getCountByTypeName(type_name)
		count = 0
		@testcases.each do |testcase|
			testcase.error_infos.each do |error_info|
				if( error_info.type == type_name )
					count += 1
				end
			end
		end
		return	count
	end
	private	:getCountByTypeName

	def	getErrorCount
		return	getCountByTypeName("error")
	end

	def	getFailureCount
		return	getCountByTypeName("fail")
	end

end
