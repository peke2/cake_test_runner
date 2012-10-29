require "open-uri"
require "nokogiri"
require "time"

class	CakeTestRunner
	TESTCASE = Struct.new(:classname, :methodname, :time, :test_infos)
	TESTINFO = Struct.new(:type, :description)

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


	#	テスト情報のノードを作成
	def	createTestInfo(node, refs_parent=true)
		test_info = TESTINFO.new()
		parent_node = node.parent()
		attr = "class"

		if refs_parent == true 
			#	親の情報を参照
			type = parent_node.get_attribute(attr)
		else
			#	自身の情報を参照
			type = node.get_attribute(attr)
		end

		test_info.type = type
		return	test_info
	end
	private	:createTestInfo


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
			test_case.test_infos = Array.new

			@testcases << test_case
			break
		end

		#	成功に関係したノードを取得
		doc.xpath("//ul[@class='tests']//li[@class='pass']").each do |node|
			#test_info = TESTINFO.new()
			#
			#parent_node = node.parent()
			#attr = "class"
			#test_info.type = parent_node.get_attribute(attr)
			test_info = createTestInfo(node, false)

			test_info.description = node.content

			test_case.test_infos << test_info
		end

		#	エラーに関係したノードを取得
		doc.xpath("//li[@class='error' or @class='fail']//div[@class='msg']").each do |node|
			#test_info = TESTINFO.new()
			#
			#parent_node = node.parent()
			#attr = "class"
			#test_info.type = parent_node.get_attribute(attr)
			test_info = createTestInfo(node)

			#	詳細情報？
			#	ノードの設定を表示してみたら「兄弟」ではなく「子供」だった…
			#	構造上、どうみても対象ノードの子供では無いような気がするのだが…
			next_node = node.next_element()

			test_info.description = node.content + "\n" + next_node.content

			test_case.test_infos << test_info
		end

	end

	#
	#	現在保持されている結果を出力
	#
	def	outputResult(filename)
		doc = Nokogiri::XML::Document.new
		doc.encoding = "utf-8"

		top_node = Nokogiri::XML::Node.new("testsuite", doc)

		error_count   = getErrorCount()
		failure_count = getFailureCount()
		pass_count    = getPassCount()

		top_node["errors"]    = error_count.to_s
		top_node["failures"]  = failure_count.to_s
		top_node["tests"]     = (error_count + failure_count + pass_count).to_s
		top_node["time"]      = "0.056"
		top_node["timestamp"] = @test_date
		doc.add_child(top_node)

		@testcases.each do |testcase|
			#	成功(pass)も含めているため、全ての状態で「testcase」を出力する
			testcase.test_infos.each do |test_info|
				node = Nokogiri::XML::Node.new("testcase", doc)
				names = testcase.classname.split(/\./)		#	拡張子部分を除去して使う
				node["classname"] = names[0]
				node["name"]      = testcase.methodname
				#node["time"]      = testcase.time
				top_node.add_child(node)

				tag_name = getTagNameByType(test_info.type)
				#	成功タグ以外の場合は内容を出力
				if !isSucceededTag(tag_name)
					error_node = Nokogiri::XML::Node.new(tag_name, doc)
					error_node["message"] = test_info.type
					error_node.content = test_info.description
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
	#	種類からタグ名を取得する
	#
	def	getTagNameByType(type_name)
		name_table = {"fail" => "failure", "error" => "error", "pass"=>"passed"}
		return	name_table[type_name]
	end


	#
	#	成功タグかどうか
	#
	def	isSucceededTag(tag)
		if tag == 'passed'; return	true; end
		return	false
	end


	#
	#	エラー、テスト失敗の数を取得
	#
	def	getCountByTypeName(type_name)
		count = 0
		@testcases.each do |testcase|
			testcase.test_infos.each do |test_info|
				if( test_info.type == type_name )
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

	def	getPassCount
		return	getCountByTypeName("pass")
	end

end
