require '../CakeTestRunner/cake_test_runner.rb'
require 'test/unit'


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
		@cake_test_runner.retrieveResult(text)

		assert_equal(1, @cake_test_runner.getErrorCount())
		assert_equal(2, @cake_test_runner.getFailureCount())

	end
end
