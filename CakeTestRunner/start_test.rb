require 'cake_test_runner'

cake_test_runner = CakeTestRunner.new
cake_test_runner.runTestByURL("http://192.168.56.102/peke2/project/cake/memo/app/webroot/test.php?case=controllers%2Fmemos_controller.test.php&app=true")
cake_test_runner.outputResult("test_result.xml")
