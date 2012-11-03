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

		assert_equal(1, @cake_test_runner.getErrorCount())
		assert_equal(2, @cake_test_runner.getFailureCount())
		assert_equal(1, @cake_test_runner.getPassCount())

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

		result = @cake_test_runner.getTagNameByType("pass")
		assert_equal("passed", result)

		result = @cake_test_runner.getTagNameByType(nil)
		assert_equal(nil, result)

		result = @cake_test_runner.getTagNameByType("dummy")
		assert_equal(nil, result)
	end

	#	����̃^�O���ǂ������`�F�b�N
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
	#	��������e�X�g�Ώۂ��擾����
	#
	def	test_retrieveTestTarget
		argv = ["test/sample", "controllers/get_unit", "models/share"]
		result = @cake_test_runner.retrieveTestTarget(argv)
		assert_equal(argv, argv)
	end

	#	�t�@�C���w��I�v�V�����t��
	def	test_retrieveTestTargetWithFileOption
		argv = ["test/sample", "-f", "target_file_list.txt" , "controllers/get_unit", "models/share"]
		result = @cake_test_runner.retrieveTestTarget(argv)

		expects = ["test/sample", "components/map", "models/items" , "controllers/get_unit", "models/share"]
		assert_equal(expects, result)
	end

	#	�w��t�@�C���������A�܂��͋�
	def	test_retrieveTestTargetWithNoFile
		argv = ["test/sample", "-f", "dummy.txt" , "controllers/get_unit", "models/share"]

		no_exists = false
		begin
			@cake_test_runner.retrieveTestTarget(argv)
		rescue Errno::ENOENT
			no_exists = true
		end
		#	�u�t�@�C�����Ȃ��v��O�Ȃ��OK
		assert(no_exists == true)

		#	���g����Ȃ�Γ��R�A���e���Ԃ��Ă��Ȃ�
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
