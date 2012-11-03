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

		assert_equal(1, @cake_test_runner.getErrorCount())
		assert_equal(2, @cake_test_runner.getFailureCount())
		assert_equal(1, @cake_test_runner.getPassCount())

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

		result = @cake_test_runner.getTagNameByType("pass")
		assert_equal("passed", result)

		result = @cake_test_runner.getTagNameByType(nil)
		assert_equal(nil, result)

		result = @cake_test_runner.getTagNameByType("dummy")
		assert_equal(nil, result)
	end

	#	正常のタグかどうかをチェック
	def	test_isSucceededTag
		result = @cake_test_runner.isSucceededTag("passed")
		assert(result == true)

		result = @cake_test_runner.isSucceededTag(nil)
		assert(result == false)

		result = @cake_test_runner.isSucceededTag('error')
		assert(result == false)

		result = @cake_test_runner.isSucceededTag('failure')
		assert(result == false)
	end

	#
	#	引数からテスト対象を取得する
	#
	def	test_retrieveTestTarget
		argv = ["test/sample", "controllers/get_unit", "models/share"]
		result = @cake_test_runner.retrieveTestTarget(argv)
		assert_equal(argv, argv)
	end

	#	ファイル指定オプション付き
	def	test_retrieveTestTargetWithFileOption
		argv = ["test/sample", "-f", "target_file_list.txt" , "controllers/get_unit", "models/share"]
		result = @cake_test_runner.retrieveTestTarget(argv)

		expects = ["test/sample", "components/map", "models/items" , "controllers/get_unit", "models/share"]
		assert_equal(expects, result)
	end

	#	指定ファイルが無い、または空
	def	test_retrieveTestTargetWithNoFile
		argv = ["test/sample", "-f", "dummy.txt" , "controllers/get_unit", "models/share"]

		no_exists = false
		begin
			@cake_test_runner.retrieveTestTarget(argv)
		rescue Errno::ENOENT
			no_exists = true
		end
		#	「ファイルがない」例外ならばOK
		assert(no_exists == true)

		#	中身が空ならば当然、内容が返ってこない
		argv = ["-f", "empty.txt", "controllers/get_unit", "models/share"]
		result = @cake_test_runner.retrieveTestTarget(argv)
		expects = ["controllers/get_unit", "models/share"]
		assert_equal(expects, result)

		argv = ["-f", "empty.txt"]
		result = @cake_test_runner.retrieveTestTarget(argv)
		expects = Array.new
		assert_equal(expects, result)
	end


end
