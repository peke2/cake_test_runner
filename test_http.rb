#
#	HTTPアクセスのテスト

require "open-uri"
#require "rexml/document"
require "nokogiri"

def readHTTP(url)
	io = open(url)
	result = io.read
	return	result
end

##result = readHTTP("http://192.168.56.102/peke2/project/cake/memo/app/webroot/test.php?case=models%2Fmemo.test.php&app=true")
#result = readHTTP("http://192.168.56.102/peke2/project/cake/memo/app/webroot/test.php?case=controllers%2Fmemos_controller.test.php&app=true")
#doc = REXML::Document.new(result)
#print result

#doc.elements.each{ |element|
#	p element
#}

#doc = Nokogiri::HTML::Document.new()
#top_node = doc.parse(open("http://192.168.56.102/peke2/project/cake/memo/app/webroot/test.php?case=controllers%2Fmemos_controller.test.php&app=true"))
##node = top_node.root()
#top_node.each do |node|
#	print node
#end

url = "http://192.168.56.102/peke2/project/cake/memo/app/webroot/test.php?case=controllers%2Fmemos_controller.test.php&app=true"

result_text = readHTTP(url)
io = File.open("result.txt", "w")
io.write(result_text)
io.close()

doc = Nokogiri::HTML(readHTTP(url))
doc.xpath("//ul[@class='tests']").each do |node|
	#	テスト時に出力されたテキストを取得
	print node.content
	print "\n"
	#	該当するテキストの次の兄弟ノードがテストの結果らしい
	print("-------- [next] --------\n");
	next_node = node.next_sibling()
	print next_node.content
	print "\n"
end

print("\n\n")

#	エラーメッセージを取り出す
print("-------- [Errors] --------\n")

doc.xpath("//li[@class='error' or @class='fail']//div[@class='msg']").each do |node|
	parent_node = node.parent()
	printf("paren name=[%s]\n", parent_node.node_name())
	attr = "class"
	printf("attribute [%s]=[%s]\n", attr, parent_node.get_attribute(attr))

	#	エラーが発生した行
	print node.content
	print "\n"
	#	詳細情報？
	#	ノードの設定を表示してみたら「兄弟」ではなく「子供」だった…
	#	構造上、どうみても対象ノードの子供では無いような気がするのだが…
	print("-------- [next] --------\n");
#	next_node = node.next_sibling()
	next_node = node.next_element()
	p next_node
	print next_node.content
	print "\n\n"
end


#	出力してみる
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

#class	MyDoc < Nokogiri::XML::SAX::Document
#	def	start_element(name, attributes=[])
#		p "found #{name}"
#		p "attr=#{attributes}"
#	end
#
#	def	end_element(name)
#		p "end #{name}"
#	end
#
#
#	def	characters(string)
#		p "chars=#{string}"
#	end
#end
#
#parser = Nokogiri::HTML::SAX::Parser.new(MyDoc.new)
#parser.parse(readHTTP("http://192.168.56.102/peke2/project/cake/memo/app/webroot/test.php?case=controllers%2Fmemos_controller.test.php&app=true"))
