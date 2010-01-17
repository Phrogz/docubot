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
		write_hhc
		write_hhk
		write_hhp
		puts "...%.2fs to write the CHM support files" % ((lap=Time.now)-lap)
		
		# This will fail if a handle is open to it on Windows
		begin
			FileUtils.rm( @chm_path ) if File.exists?( @chm_path )
		rescue Errno::EACCES
			require 'win32ole'
			for process in WIN32OLE.connect("winmgmts://").ExecQuery("select Name,CommandLine from win32_process where Name='hh.exe'") do
				process.Terminate if process.CommandLine.include? @chm_path.gsub('/','\\')
			end
		end
		`hhc.exe "#{FileUtils.win_path @hhp}"`.gsub( /[\r\n]+/, "\n" )
		puts "...%.2fs to create the CHM" % ((lap=Time.now)-lap)
		
		# Clean out the intermediary files
		FileUtils.rm( [ @hhc, @hhp, @hhk ] )
		FileUtils.rm_r( @html_path )
		puts "...%.2fs to clean up temporary files" % ((lap=Time.now)-lap)
		
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

		if @toc.default?
			# User tried to specify the default page
			@default_topic = @toc.descendants.find{ |page| page.title==@toc.default }
			if @default_topic
				if @default_topic.file =~ /\s/
					warn "'#{@toc.default}' cannot be the default CHM page; it has a space in the file name."
					@default_topic = nil
				end
			else
				warn "The requested default page '#{@toc.default}' could not be found. (Did the title change?)"
			end
		end
		@default_topic ||= @toc.descendants.find{ |page| page.file =~ /^\S+$/ }
		warn "No default page is set, because no page has a file name without spaces." unless @default_topic

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