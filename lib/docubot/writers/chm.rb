require DocuBot::Writer::DIR / 'html'
require 'cgi'
require 'erb'
class DocuBot::CHMWriter < DocuBot::HTMLWriter
	handles_type :chm
	
	SUPPORT = DocuBot::Writer::DIR / 'chm'
	
	def write( destination=nil )
		super( nil )
		lap = Time.now
		@chm_path = destination || "#{@bundle.source}.chm"
		@toc = @bundle.toc
		@global = @bundle.global
		write_hhc
		write_hhk
		write_hhp
		puts "...%.2fs to write the CHM support files" % (Time.now-lap)
		lap = Time.now
		
		# This will fail if a handle is open to it on Windows
		begin
			FileUtils.rm( @chm_path ) if File.exists?( @chm_path )
		rescue Errno::EACCES
			require 'win32ole'
			for process in WIN32OLE.connect("winmgmts://").ExecQuery("select Name,CommandLine from win32_process where Name='hh.exe'") do
				process.Terminate if process.CommandLine.include? @chm_path.gsub('/','\\')
			end
		end
		
		# Help find hhc.exe
		possible_hhc_spots = [ "C:\\Program Files\\HTML Help Workshop", "C:\\Program Files (x86)\\HTML Help Workshop" ]
		path_directories   = ENV['PATH'].split(';').concat( possible_hhc_spots )
		ENV['PATH'] = path_directories.join(';')
		unless path_directories.any?{ |dir| File.exists?( File.join(dir, 'hhc.exe' ) ) }
			warn "Cannot find hhc.exe in your PATH or the standard install spots.\nDid you install HTML Help Workshop?"
			FileUtils.rm( [ @hhc, @hhp, @hhk ] )
			FileUtils.rm_r( @html_path )
			exit 1
		end
		
		`hhc.exe "#{FileUtils.win_path @hhp}"`.gsub( /[\r\n]+/, "\n" )
		puts "...%.2fs to create the CHM" % (Time.now-lap)
		lap = Time.now
		
		# Clean out the intermediary files
		FileUtils.rm( [ @hhc, @hhp, @hhk ] )
		FileUtils.rm_r( @html_path )
		puts "...%.2fs to clean up temporary files" % (Time.now-lap)
		lap = Time.now
		
		# Spin a new thread so it doesn't hold up the Ruby process, but sleep long enough for it to get going.
		Thread.new{ `hh.exe "#{FileUtils.win_path @chm_path}"` }
		sleep 0.1 if Object.const_defined? "Encoding" # This sleep does not help on 1.8.6
	end

	def write_hhc
		@hhc = @chm_path.sub( /[^.]+$/, 'hhc' )
		File.open( @hhc, 'w' ) do |f|
			f << ERB.new( IO.read( SUPPORT / 'hhc.erb' ) ).result( binding )
		end
	end

	def write_hhp
		@hhp = @chm_path.sub( /[^.]+$/, 'hhp' )

		if @global.default
			# User tried to specify the default page
			@default_topic = @bundle.pages_by_title[ @global.default ].first
			if @default_topic
				if @default_topic.file =~ /\s/
					warn "'#{@toc.default}' cannot be the default CHM page; it has a space in the file name."
					@default_topic = nil
				end
			else
				warn "The requested default page '#{@global.default}' could not be found. (Did the title change?)"
			end
		end
		@default_topic ||= @toc.descendants.find{ |node| node.link =~ /^\S+$/ }
		warn "No default page is set, because no page has a path without spaces." unless @default_topic

		File.open( @hhp, 'w' ) do |f|
			f << ERB.new( IO.read( SUPPORT / 'hhp.erb' ) ).result( binding )
		end
	end

	def write_hhk
		@hhk = @chm_path.sub( /[^.]+$/, 'hhk' )
		File.open( @hhk, 'w' ) do |f|
			f << ERB.new( IO.read( SUPPORT / 'hhk.erb' ) ).result( binding )
		end
	end
end