code = /^[ \t]*[^#\r\n]/
full = /^[ \t]*\S/
raw_kinds = {
	'Test content'   => 'spec/samples/**/*',
	'Haml templates' => 'lib/docubot/templates/*.haml',
	'CSS'            => 'lib/docubot/templates/**/*.css',
	'JS'             => 'lib/docubot/templates/**/*.js',
}
code_kinds = {
	'Library code'  => 'lib/**/*.rb',
	'Spec code'     => 'spec/**/*.rb',
	'Executable'    => 'bin/docubot',
}

max_label_length = (raw_kinds.keys + code_kinds.keys).map(&:length).max

matches = {
	code_kinds=>code,
	raw_kinds=>full
}

matches.each do |kinds, regexp|
	kinds.each do |desc,glob|
		hits = Dir[glob].inject(0) do |lines,file|
			unless File.directory?(file)
				File.open(file){ |f| f.each_line{ |line| lines += 1 if line[regexp] } }
			end
			lines
		end
		puts "%-#{max_label_length}s: %d" % [ desc, hits ]
	end
end
