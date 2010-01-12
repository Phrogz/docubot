require 'cgi'
require 'erb'
class DocuBot::CHMWriter
	extend DocuBot::Writer
	handles_type :chm, :CHM
	
	SUPPORT = DocuBot::Writer::DIR / 'chm'
	
	def initialize( bundle )
		@bundle = bundle
	end
	
	def write( chm_path )
		write_hhc( chm_path )
		write_hhp( chm_path )
		write_hhk( chm_path )
		FileUtils.rm_f( chm_path )
		puts `hhc.exe "#{FileUtils.win_path @hhp}"`.gsub( /[\r\n]+/, "\n" )
	end
	
	def write_hhc( chm_path )
		@hhc = chm_path.sub( /[^.]+$/, 'hhc' )
		File.open( @hhc, 'w' ) do |f|
			f << ERB.new( IO.read( SUPPORT / 'hhc.erb' ) ).result( binding )
		end
	end

	def write_hhp( chm_path )
		@hhp = chm_path.sub( /[^.]+$/, 'hhp' )
		File.open( @hhp, 'w' ) do |f|
			f << ERB.new( IO.read( SUPPORT / 'hhp.erb' ) ).result( binding )
		end
	end

	def write_hhk( chm_path )
		@hhk = chm_path.sub( /[^.]+$/, 'hhk' )
		File.open( @hhk, 'w' ) do |f|
			f << ERB.new( IO.read( SUPPORT / 'hhk.erb' ) ).result( binding )
		end
	end
end