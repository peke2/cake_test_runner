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

#result = readHTTP("http://192.168.56.102/peke2/project/cake/memo/app/webroot/test.php?case=models%2Fmemo.test.php&app=true")
#result = readHTTP("http://192.168.56.102/peke2/project/cake/memo/app/webroot/test.php?case=controllers%2Fmemos_controller.test.php&app=true")
#doc = REXML::Document.new(result)
#print result

#doc.elements.each{ |element|
#	p element
#}

doc = Nokogiri::HTML::Document.new()
top_node = doc.parse(open("http://192.168.56.102/peke2/project/cake/memo/app/webroot/test.php?case=controllers%2Fmemos_controller.test.php&app=true"))
#node = top_node.root()
top_node.each do |node|
	print node
end

#doc.xpath('//hs/a').each do |link|
#	p link.content
#end


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
