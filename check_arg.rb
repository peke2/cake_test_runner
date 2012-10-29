# 実行時の引数確認

require 'uri'

ARGV.each do |arg|
	#	クエリの引数部分のみを対応とする
	printf("[%s] -> [%s]\n", arg, URI.encode(arg, "/"));
end

