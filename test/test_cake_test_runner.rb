require '../CakeTestRunner/cake_test_runner.rb'
require 'test/unit'
require 'time'

class TestCakeTestRunner < Test::Unit::TestCase
	def	setup
		@cake_test_runner = CakeTestRunner.new
	end

	def	teardown
	end

	#	���ʎ��o���m�F
	def	test_retrieveResult
		io = File.open('test_result.txt', "r")
		text = io.read()
		io.close()
		@cake_test_runner.retrieveResult(text, Time.now)

		assert_equal(1, @cake_test_runner.getErrorCount())
		assert_equal(2, @cake_test_runner.getFailureCount())
	end

	#	���ʏo�͂̊m�F
	def	test_outputResult
		io = File.open('test_result.txt', "r")
		text = io.read()
		io.close()

		@cake_test_runner.retrieveResult(text, Time.now)
		@cake_test_runner.outputResult("test_result.xml")
	end

	#	URL��ΏۂƂ����m�F
	def	test_outputResultWithURL
		#@cake_test_runner.runTestByURL("http://192.168.56.102/peke2/project/cake/memo/app/webroot/test.php?case=controllers%2Fmemos_controller.test.php&app=true")
		#@cake_test_runner.outputResult("test_result.xml")
	end

	#	�����̓����g�p�`���ւ̕ϊ��m�F
	def	test_convertDateTime
		#datetime = File.mtime("test_result.txt")
		datetime = Time.mktime(2012,10,28,21,40,05)
	#	p datetime

		result = @cake_test_runner.convertDateTime(datetime)
		assert_equal("2012-10-28T21:40:05+09:00", result)
	end

	#	��ނƃ^�O���̊m�F
	def	test_getTagNameByType
		result = @cake_test_runner.getTagNameByType("fail")
		assert_equal("failure", result)

		result = @cake_test_runner.getTagNameByType("error")
		assert_equal("error", result)

		result = @cake_test_runner.getTagNameByType(nil)
		assert_equal(nil, result)

		result = @cake_test_runner.getTagNameByType("dummy")
		assert_equal(nil, result)
	end

end
