# Dump Rom Detail, and Serve Box Art from: https://emumovies.com/files/file/3119-sega-naomi-2d-boxes-with-discs-151/
require 'webrick'
include WEBrick

s = HTTPServer.new( 
:Port => 80, 
:DocumentRoot     => "RomBINS" 
)

def dissect(rom)
	require 'hexdump'

	htmldata = ""
	romdata = File.binread(rom,880)
	puts  "Reading values from " + rom + "\n"
	tmpout = ""	
	# Only 16 bytes here 
	# NAOMI header
	htmldata +=  "<br>Platform<br>"
	Hexdump.dump(romdata[0..15], :output => tmpout, :ascii => true)
	tmpout = tmpout.gsub("\n","<br>")
	htmldata += tmpout

	# Print out 32 bytes at a time from now on 
	# Company Name
	htmldata +=  "<br>Company<br>"
	Hexdump.dump(romdata[16..47], :output => tmpout, :ascii => true)
	tmpout = tmpout.gsub("\n","<br>")
	htmldata += tmpout

	htmldata +=  "<br>Game Name by region"
	# Game Name (JAPAN)
	Hexdump.dump(romdata[48..79], :output => tmpout, :ascii => true)
	tmpout = tmpout.gsub("\n","<br>")
	htmldata += "<br>JAPAN<BR>" + tmpout
	# Game Name (USA)
	Hexdump.dump(romdata[80..111], :output => tmpout, :ascii => true)
	tmpout = tmpout.gsub("\n","<br>")
	htmldata += "<br>USA<BR>" + tmpout
	# Game Name (EXPORT/EURO)
	Hexdump.dump(romdata[112..143], :output => tmpout, :ascii => true)
	tmpout = tmpout.gsub("\n","<br>")
	htmldata += "<br>EURO<BR>" + tmpout
	# Game Name (KOREA/ASIA)
	Hexdump.dump(romdata[144..175], :output => tmpout, :ascii => true)
	tmpout = tmpout.gsub("\n","<br>")
	htmldata += "<br>KOREA/ASIA<br>" + tmpout
	# Game Name (AUSTRALIA)
	Hexdump.dump(romdata[176..207], :output => tmpout, :ascii => true)
	tmpout = tmpout.gsub("\n","<br>")
	htmldata += "<br>AUSTRALIA<BR>" + tmpout
	# Game Name (SAMPLE GAME / RESERVED 1 / RESERVED ?)
	Hexdump.dump(romdata[208..239], :output => tmpout, :ascii => true)
	tmpout = tmpout.gsub("\n","<br>")
	htmldata += "<br>RESERVED 1<br>" + tmpout
	# Game Name (SAMPLE GAME / RESERVED 2 / RESERVED !)
	Hexdump.dump(romdata[240..271], :output => tmpout, :ascii => true)
	tmpout = tmpout.gsub("\n","<br>")
	htmldata += "<br>RESERVED 2<br>" + tmpout
	# Game Name (SAMPLE GAME / RESERVED 3 / RESERVED @)
	Hexdump.dump(romdata[272..303], :output => tmpout, :ascii => true)
	tmpout = tmpout.gsub("\n","<br>")
	htmldata += "<br>RESERVED 3<br>" + tmpout

	# Game ID
	htmldata +=  "<br>Game ID<br>"
	Hexdump.dump(romdata[304..335], :output => tmpout, :ascii => true)
	tmpout = tmpout.gsub("\n","<br>")
	htmldata += tmpout

	# Entry Point
	htmldata +=  "<br>Entry Point: " + romdata[420..423].unpack('H*').to_s + "<br>"

	# 0x360 is magic... aka 864 in binary 
	htmldata +=  "<br>ROM Capacity<br>" 
	capacity1 = romdata[864..867]
	capacity2 = romdata[868..871]
	capacity3 = romdata[872..875]
	capacity4 = romdata[876..879]
	htmldata +=  "Start: " + capacity1.unpack('h*').to_s + "<br>"
	htmldata +=  "End: " + capacity2.unpack('h*').to_s + "<br>"
	htmldata +=  "Ram address: " + capacity3.unpack('h*').to_s + "<br>"
	#htmldata +=  capacity4.unpack('h*')
	
	return htmldata + "<br> --------------------------------------------------------------------------------------------------- <br><br>"
end

class ROMRUNNER < WEBrick::HTTPServlet::AbstractServlet
 def do_GET(req, res)
        ip = "192.168.1.95"
	rompath = "./" + req.path_info.gsub('roms', 'RomBINS')
	puts rompath

	if File.file?(rompath)
		puts "Rom file present... "
		parent_pid = Process.spawn("./netboot_upload_tool", "#{ip}", "#{rompath}")
	else
		puts "No rom file!"
	end

	html = "<html><body>Naomi1<br>" + "<a href='../../../'>..</a><br>"
	html += "./#{rompath} launched with pid: #{parent_pid}"
        res.body = html
        res['Content-Type'] = "text/html"
 end
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
				p "Dissecting #{rom}"
				html += "<a href='" + req.unparsed_uri + rom + "'>Download: " + rom + "</a><br>"
				html += "<a href='" + "/execute" + req.unparsed_uri + rom + "'>Execute: " + rom + "</a><br>"
				html += dissect(rom)				
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
				html += "<a href='" + req.unparsed_uri + rom + "'>Download: " + rom + "</a><br>"
				html += "<a href='" + "/execute" + req.unparsed_uri + rom + "'>Execute: " + rom + "</a><br>"
				html += dissect(rom)
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
				html += "<a href='" + req.unparsed_uri + rom + "'>Download: " + rom + "</a><br>"
				html += "<a href='" + "/execute" + req.unparsed_uri + rom + "'>Execute: " + rom + "</a><br>"
				html += dissect(rom)
                        }
		end
                html += "</body></html>"
                res.body = html
                res['Content-Type'] = "text/html"

        elsif req.unparsed_uri == "/roms/Chihiro/"
                html = "<html><body>Chihiro<br>Currently unable to parse Chihiro roms to display more data<br>" + "<a href='../../'>..</a><br>"
		Dir.chdir("RomBINS/Chihiro") do
			chihirofiles = Dir.glob("*").sort_by(&:downcase)
			chihirofiles.each{|rom|
				html += "<a href='" + req.unparsed_uri + rom + "'>Download: " + rom + "</a><br>"
				html += "<a href='" + "/execute" + req.unparsed_uri + rom + "'>Execute: " + rom + "</a><br>"
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
				html += "<a href='" + req.unparsed_uri + rom + "'>Download: " + rom + "</a><br>"
				html += "<a href='" + "/execute" + req.unparsed_uri + rom + "'>Execute: " + rom + "</a><br>"
				html += dissect(rom)
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
s.mount("/execute", ROMRUNNER)
s.mount("/roms", ROMFILEZ, "RomBINS")
s.mount("/", ROMS)
s.start


