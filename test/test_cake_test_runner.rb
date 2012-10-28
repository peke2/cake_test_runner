require '../CakeTestRunner/cake_test_runner.rb'
require 'test/unit'
require 'time'

class TestCakeTestRunner < Test::Unit::TestCase
	def	setup
		@cake_test_runner = CakeTestRunner.new
	end

	def	teardown
	end

	def	test_retrieveResult
		io = File.open('test_result.txt', "r")
		text = io.read()
		io.close()
		@cake_test_runner.retrieveResult(text, Time.now)

		assert_equal(1, @cake_test_runner.getErrorCount())
		assert_equal(2, @cake_test_runner.getFailureCount())
	end

	def	test_outputResult
		io = File.open('test_result.txt', "r")
		text = io.read()
		io.close()

		@cake_test_runner.retrieveResult(text, Time.now)
		@cake_test_runner.outputResult("test_result.xml")
	end


	def	test_outputResultWithURL
		@cake_test_runner.runTestByURL("http://192.168.56.102/peke2/project/cake/memo/app/webroot/test.php?case=controllers%2Fmemos_controller.test.php&app=true")

		@cake_test_runner.outputResult("test_result.xml")
	end


	def	test_convertDateTime
		#datetime = File.mtime("test_result.txt")
		datetime = Time.mktime(2012,10,28,21,40,05)
	#	p datetime

		result = @cake_test_runner.convertDateTime(datetime)
		assert_equal("2012-10-28T21:40:05+09:00", result)
	end

end
