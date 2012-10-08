#	HTTPアクセスのテスト

require "open-uri"

def readHTTP(url)
	io = open(url)
	result = io.read
	return	result
end


result = readHTTP("http://192.168.56.102/peke2/project/cake/memo/test.php")
p result
