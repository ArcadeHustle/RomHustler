require 'webrick'
include WEBrick

s = HTTPServer.new( 
:Port => 80, 
:DocumentRoot     => "RomBINS" 
)

def dissect(rom)
	require 'hexdump'

	romdata = File.binread(rom,880)
	puts "Reading values from " + rom + ":\n"

	# Only 16 bytes here 
	# NAOMI header
	puts "-----------------------------------------------------------------------------\n"
	puts "Platform"
	Hexdump.dump(romdata[0..15])

	# Print out 32 bytes at a time from now on 
	# Company Name
	puts "-----------------------------------------------------------------------------\n"
	puts "Company"
	Hexdump.dump(romdata[16..47])

	# Game Name (JAPAN)
	puts "-----------------------------------------------------------------------------\n"
	puts "Game Name by region"
	Hexdump.dump(romdata[48..79])
	# Game Name (USA)
	Hexdump.dump(romdata[80..111])
	# Game Name (EXPORT/EURO)
	Hexdump.dump(romdata[112..143])
	# Game Name (KOREA/ASIA)
	Hexdump.dump(romdata[144..175])
	# Game Name (AUSTRALIA)
	Hexdump.dump(romdata[176..207])
	# Game Name (SAMPLE GAME / RESERVED 1 / RESERVED ?)
	Hexdump.dump(romdata[208..239])
	# Game Name (SAMPLE GAME / RESERVED 2 / RESERVED !)
	Hexdump.dump(romdata[240..271])
	# Game Name (SAMPLE GAME / RESERVED 3 / RESERVED @)
	Hexdump.dump(romdata[272..303])

	# Game ID
	puts "-----------------------------------------------------------------------------\n"
	puts "Game ID"
	Hexdump.dump(romdata[304..335])

	# Entry Point
	puts "-----------------------------------------------------------------------------\n"
	puts "Entry Point: " + romdata[420..423].unpack('H*').to_s

	# 0x360 is magic... aka 864 in binary 
	puts "-----------------------------------------------------------------------------\n"
	puts "ROM Capacity"
	capacity1 = romdata[864..867]
	capacity2 = romdata[868..871]
	capacity3 = romdata[872..875]
	capacity4 = romdata[876..879]
	puts "Start: " + capacity1.unpack('h*').to_s
	puts "End: " + capacity2.unpack('h*').to_s
	puts "Ram address: " + capacity3.unpack('h*').to_s
	#puts capacity4.unpack('h*')

end

class ROMFILEZ < WEBrick::HTTPServlet::FileHandler
 def do_GET(req, res)
        p "Req #{req.unparsed_uri}"
	Dir.chdir("RomBINS") do
		rombinfiles = Dir.glob("*").sort_by(&:downcase)
	end

        if req.unparsed_uri == "/roms/Naomi1/"
                html = "<html><body>Naomi1<br>" + "<a href='../../'>..</a><br>"
		Dir.chdir("RomBINS/Naomi1") do
			naomi1files = Dir.glob("*").sort_by(&:downcase)
			naomi1files.each{|rom|
				html += "<a href='" + req.unparsed_uri + rom + "'>" + rom + "</a></br>"
				dissect(rom)				
			}
		end
                html += "</body></html>"
                res.body = html
                res['Content-Type'] = "text/html"

        elsif req.unparsed_uri == "/roms/Naomi2/"
                html = "<html><body>Naomi2<br>" + "<a href='../../'>..</a><br>"
		Dir.chdir("RomBINS/Naomi2") do
			naomi2files = Dir.glob("*").sort_by(&:downcase)
			naomi2files.each{|rom|
                                html += "<a href='" + req.unparsed_uri + rom + "'>" + rom + "</a></br>"
				dissect(rom)
                        }
		end
                html += "</body></html>"
                res.body = html
                res['Content-Type'] = "text/html"

        elsif req.unparsed_uri == "/roms/AtomisWave/"
                html = "<html><body>AtomisWave<br>" + "<a href='../../'>..</a><br>"
		Dir.chdir("RomBINS/AtomisWave") do
			atomiswavefiles = Dir.glob("*").sort_by(&:downcase)
			atomiswavefiles.each{|rom|
                                html += "<a href='" + req.unparsed_uri + rom + "'>" + rom + "</a></br>"
				dissect(rom)
                        }
		end
                html += "</body></html>"
                res.body = html
                res['Content-Type'] = "text/html"

        elsif req.unparsed_uri == "/roms/Chihiro/"
                html = "<html><body>Chihiro<br>" + "<a href='../../'>..</a><br>"
		Dir.chdir("RomBINS/Chihiro") do
			chihirofiles = Dir.glob("*").sort_by(&:downcase)
			chihirofiles.each{|rom|
                                html += "<a href='" + req.unparsed_uri + rom + "'>" + rom + "</a></br>"
                        }
		end
                html += "</body></html>"
                res.body = html
                res['Content-Type'] = "text/html"

        elsif req.unparsed_uri == "/roms/Firmware/"
                html = "<html><body>Firmware<br>" + "<a href='../../'>..</a><br>"
		Dir.chdir("RomBINS/Firmware") do
			firmwarefiles = Dir.glob("*").sort_by(&:downcase)
			firmwarefiles.each{|rom|
                                html += "<a href='" + req.unparsed_uri + rom + "'>" + rom + "</a></br>"
				dissect(rom)
                        }
		end
                html += "</body></html>"
                res.body = html
                res['Content-Type'] = "text/html"

        else       
                print "Calling Super"
                super
        end
 end
end

class ROMS < HTTPServlet::AbstractServlet
 def do_GET(req, res)
        if req.unparsed_uri == "/"
		# AtomisWave  Chihiro Firmware  Naomi1  Naomi2  Triforce
		html = "<html><body><a href='/roms/Naomi1'>Naomi1 Roms</a><br>"
		html += "<a href='/roms/Naomi2'>Naomi2 Roms</a></body></html><br>"
		html += "<a href='/roms/AtomisWave'>AtomisWave Roms</a></body></html><br>"
		html += "<a href='/roms/Chihiro'>Chihiro Roms</a></body></html><br>"
		html += "<a href='/roms/Firmware'>Firmware Roms</a></body></html><br>"
		html += "</body></html>"
        	res.body = html
        	res['Content-Type'] = "text/html"
	end
 end
end

trap("INT"){ s.shutdown }
s.mount("/roms", ROMFILEZ, "RomBINS")
s.mount("/", ROMS)
s.start


