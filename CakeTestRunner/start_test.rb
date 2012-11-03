require './cake_test_runner'
require 'uri'

url = "http://192.168.56.102/peke2/project/cake/memo/app/webroot/test.php"
params = "app=true&show_passes=1"

cake_test_runner = CakeTestRunner.new
#cake_test_runner.runTestByURL("http://192.168.56.102/peke2/project/cake/memo/app/webroot/test.php?case=controllers%2Fmemos_controller.test.php&app=true")

targets = cake_test_runner.retrieveTestTarget(ARGV)

targets.each { |target|
	uri = sprintf("%s?case=%s&%s", url, URI.encode(target,"/"), params )
	cake_test_runner.runTestByURL(uri)
}
cake_test_runner.outputResult("test_result.xml")
