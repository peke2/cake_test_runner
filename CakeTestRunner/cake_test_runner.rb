require "nokogiri"

class	CakeTestRunner
	TESTCASE = Struct.new(:classname, :methodname, :time, :error_infos)
	ERRORINFO = Struct.new(:type, :description)

	@testcases

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
		convertResult( readHTTP(url) )
	end


	#
	#	テスト結果のテキストから必要な情報を取得する
	#
	def	retrieveResult(result_text)
		doc = Nokogiri::HTML(result_text)

		test_case = TESTCASE.new

		#<div  class="test-results"><h2>Individual test case: controllers/memos_controller.test.php</h2>
		doc.xpath("//div[@class='test-results']").each do |node|
			#とりあえず、最初に見つけた1つのみを取得
			#実際は単体でテストを起動するので1つしか無い気がする
			test_case.classname = node.content
			test_case.error_infos = Array.new

			@testcases << test_case
			break
		end

		#	エラーに関係したノードを取得
		doc.xpath("//li[@class='error' or @class='fail']//div[@class='msg']").each do |node|
			error_info = ERRORINFO.new()

			parent_node = node.parent()
		#	printf("paren name=[%s]\n", parent_node.node_name())
			attr = "class"
		#	printf("attribute [%s]=[%s]\n", attr, parent_node.get_attribute(attr))
			error_info.type = parent_node.get_attribute(attr)

			#	エラーが発生した行
		#	print node.content
		#	print "\n"
			

			#	詳細情報？
			#	ノードの設定を表示してみたら「兄弟」ではなく「子供」だった…
			#	構造上、どうみても対象ノードの子供では無いような気がするのだが…
		#	print("-------- [next] --------\n");
			#next_node = node.next_sibling()
			next_node = node.next_element()
		#	p next_node
		#	print next_node.content
		#	print "\n\n"

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
		top_node["errors"] = "1"
		top_node["failures"] = "1"
		top_node["tests"] = "2"
		top_node["time"] = "0.056"
		top_node["timestamp"] = "2012-10-28T19:45:00"
		doc.add_child(top_node)

		node = Nokogiri::XML::Node.new("testcase", doc)
		node["classname"] = "DummyClass"
		node["name"] = "dummyMethod"
		node["time"] = "0.0345"
		top_node.add_child(node)

		error_node = Nokogiri::XML::Node.new("error", doc)
		error_node["message"] = "ERROR"
		error_node.content = "Syntax error on DummyFile.php in line 123"
		node.add_child(error_node)

		error_node = Nokogiri::XML::Node.new("failure", doc)
		error_node["message"] = "FAILURE"
		error_node.content = "Assertion failed"
		node.add_child(error_node)

		io = File.open("output.xml", "w")
		doc.write_xml_to(io)
		io.close()
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
