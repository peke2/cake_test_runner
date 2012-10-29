require './cake_test_runner'
require 'uri'

url = "http://192.168.56.102/peke2/project/cake/memo/app/webroot/test.php"
params = "app=true"

cake_test_runner = CakeTestRunner.new
#cake_test_runner.runTestByURL("http://192.168.56.102/peke2/project/cake/memo/app/webroot/test.php?case=controllers%2Fmemos_controller.test.php&app=true")

ARGV.each do |arg|
	uri = sprintf("%s?case=%s&%s", url, URI.encode(arg,"/"), params )
	cake_test_runner.runTestByURL(uri)
end
cake_test_runner.outputResult("test_result.xml")
