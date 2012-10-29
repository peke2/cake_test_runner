require '../CakeTestRunner/cake_test_runner.rb'
require 'test/unit'
require 'time'

class TestCakeTestRunner < Test::Unit::TestCase
	def	setup
		@cake_test_runner = CakeTestRunner.new
	end

	def	teardown
	end

	#	結果取り出し確認
	def	test_retrieveResult
		io = File.open('test_result.txt', "r")
		text = io.read()
		io.close()
		@cake_test_runner.retrieveResult(text, Time.now)

		assert_equal(1, @cake_test_runner.getErrorCount())
		assert_equal(2, @cake_test_runner.getFailureCount())
	end

	#	結果出力の確認
	def	test_outputResult
		io = File.open('test_result.txt', "r")
		text = io.read()
		io.close()

		@cake_test_runner.retrieveResult(text, Time.now)
		@cake_test_runner.outputResult("test_result.xml")
	end

	#	URLを対象とした確認
	def	test_outputResultWithURL
		#@cake_test_runner.runTestByURL("http://192.168.56.102/peke2/project/cake/memo/app/webroot/test.php?case=controllers%2Fmemos_controller.test.php&app=true")
		#@cake_test_runner.outputResult("test_result.xml")
	end

	#	日時の内部使用形式への変換確認
	def	test_convertDateTime
		#datetime = File.mtime("test_result.txt")
		datetime = Time.mktime(2012,10,28,21,40,05)
	#	p datetime

		result = @cake_test_runner.convertDateTime(datetime)
		assert_equal("2012-10-28T21:40:05+09:00", result)
	end

	#	種類とタグ名の確認
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
