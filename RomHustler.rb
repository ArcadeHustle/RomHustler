# Requires patched netboot_upload_tool
# https://github.com/ArcadeHustle/naomi_netboot_upload.git

require 'webrick'
require 'uri'
require 'hexdump'
include WEBrick

s = HTTPServer.new( 
:Port => 80, 
:DocumentRoot     => "RomBINS" 
)

def get_running_netboots()
	ps = %x[ps -ax]
        processes = Array.new
        ps.split("\n").each{ |target|
                if target =~  /netboot_upload_tool/
                        processes <<  target
                end
        }
	p processes
        return processes	
end

def get_dhcp_hosts()
	#1533358708 00:d0:f1:01:de:56 192.168.1.95 * 01:00:d0:f1:01:de:56
	#1533360065 00:d0:f1:02:1e:4e 192.168.1.191 * 01:00:d0:f1:02:1e:4e

	dhcp = File.read("/var/lib/misc/dnsmasq.leases")

	hosts = Array.new
	dhcp.split("\n").each{ |target|
        	if target =~  /00:d0:f1/
                	hosts <<  [target.split()[1], target.split()[2]]
        	end
	}
	return hosts
end
def dissect(rom)

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

class ROMKILLER < WEBrick::HTTPServlet::AbstractServlet
 def do_GET(req, res)
	cleanurl = URI.decode(req.unparsed_uri).split("=")
	# ["/kill?pidtokill", "13488+pts/1++++S++++++0:00+./netboot_upload_tool+192.168.1.191+RomBINS/AtomisWave/AW-MetalSlug6.bin"]
	pid = cleanurl[1].split("+")[0]
	host =  cleanurl[1].split("/")[2].split("+")[1]
	rombin = cleanurl[1].split("/")[4]
        html = "<html><body>"
        html += "<a href='/'>..</a><br>Killing pid: #{pid} #{rombin} running on #{host}<br>"
	html += "</body></html>"
        res.body = html
        res['Content-Type'] = "text/html"
	%x[kill -9 #{pid}]
 end
end

class ROMRUNNER < WEBrick::HTTPServlet::AbstractServlet
 def do_GET(req, res)
	# /execute?RomBin=AtomisWave%2FAW-GuiltyGearIsuka.bin&NetDimm=192.168.1.95-00%3Ad0%3Af1%3A01%3Ade%3A56
	cleanurl = URI.decode(req.unparsed_uri).split("=")
	# ["/execute?RomBin", "AtomisWave/AW-GuiltyGearIsuka.bin&NetDimm", "192.168.1.191-00:d0:f1:02:1e:4e"]
	p cleanurl
	# ["/execute?RomBin", "AtomisWave/ftspeed.bin&NetDimm", "manual&host", "192.168.1.197&port", "10703"]
	if cleanurl[2] =~ /manual/
		puts "found manual in clean url"
		ip = cleanurl[3].split("&")[0]
		port = cleanurl[4]
	else
		puts "found nothing"
	        ip = cleanurl[2].split("-")[0] 
		port = cleanurl[4]
	end
	# Need to check for manual entries
	# http://192.168.1.252/execute?RomBin=blank&NetDimm=manual&host=10.0.0.1&port=10703 -> /

	rompath = "RomBINS/" + cleanurl[1].split("&")[0] 

	if File.file?(rompath)
		puts "Rom file present... "

		get_running_netboots().each{ |running|
			if running =~ /#{ip}/
				killpid = running.split(" ")[0]
				%x[kill -9 #{killpid}]
			end
			puts "Addempted to kill #{killpid}"
		}

		parent_pid = Process.spawn("./netboot_upload_tool", "#{ip}", "#{port}","#{rompath}")
		html = "<html><body>" + "<a href='../../../'>..</a><br>"
		html += "./#{rompath} launched with pid: #{parent_pid}"
	        res.body = html
	        res['Content-Type'] = "text/html"
	else
		html = "<html><body>" + "<a href='../../../'>..</a><br>"
		html += "No rom file!</html>"
        	res.body = html
        	res['Content-Type'] = "text/html"
	end

	# Once rom is run, add PID, host, and IF game is not rebootable, or IF game is known to change IP
	# Store in SQLite? or Serialize?
	# https://www.arcade-projects.com/forums/index.php?thread/5255-games-that-reassign-ip-address-after-netbooting/&pageNo=1
 end
end


class ROMFILEZ < WEBrick::HTTPServlet::FileHandler
 def do_GET(req, res)
        p "Req #{req.unparsed_uri}"
        super
 end
end

class ROMS < HTTPServlet::AbstractServlet
 def do_GET(req, res)
        if req.unparsed_uri == "/"
		html = "<html><body>"
                html += "<br><img id=\"imageToSwap\" src=\"RomBINS/hustle.jpg\" height=\"300\" width=\"300\">"
		html += "<br>Select the Platform type and game ROM<br>"
		html += "<form action=\"/execute\" method=\"get\">" 
		html += "<script src=\"https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js\" type=\"text/javascript\"></script>"
		# Use Art from https://emumovies.com/files/file/3119-sega-naomi-2d-boxes-with-discs-151/
		# https://emumovies.com/files/file/1965-atomiswave-flyers/
		html += "<select name='RomBin' onchange=\"$('#imageToSwap').attr('src', '/roms/' + this.options[this.selectedIndex].value + '.jpg');\">"
		html += "<option value='blank'></option>"
                Dir.chdir("RomBINS/") do
                        files = Dir.glob("*/*").sort_by(&:downcase)
                        files.each{|rom|
				if rom =~ /.jpg/
					p "nope"
				else
		                	html += "<option value=\"#{rom}\">#{rom}</option>"
				end
                        }
                end
		html += "</select>"

		html += "<br>Select a NetDIMM based DHCP host or choose manual and enter it yourself<br>"
		html += "<select name='NetDimm'>"
		html += "<option value='blank'></option>"
		html += "<option value='manual'>Manual Entry</option>"
		get_dhcp_hosts().each{ |host|
			html += "<option value='#{host[1]}-#{host[0]}'>#{host[1]}</option>"
		}

		# any way to show this only on option select Manual? 
		html += "</select><br><br>Hostname, or IP for Manual entry:<br>"
		html += "<input type=\"text\" name=\"host\"><br>"
		html += "Port (default is 10703):<br>"
		html += "<input type=\"text\" name=\"port\" value=\"10703\">"		

		html += "<br><br>Click Launch to start the game<br>"
		html += "<input type=\"submit\" value=\"Launch\"></form>"

		html += "Alternately, Select a running game to kill<br>"
		html += "<form action=\"/kill\" method=\"get\"><select name='pidtokill'>"
		get_running_netboots().each{ |pid|
			p pid
			html += "<option value=\"#{pid}\">#{pid}</option>"
		}
		html += "</select>"
		html += "<input type=\"submit\" value=\"Kill\"></form>"
		html += "</body></html>"
        	res.body = html
        	res['Content-Type'] = "text/html"

        elsif req.unparsed_uri =~ /NetDimm/
                html = "<html><body>"
                html += "<a href='/'>..</a><br>Pushing rom to host<br>"
		html += "</body></html>"
                res.body = html
                res['Content-Type'] = "text/html"
	end
 end
end

trap("INT"){ s.shutdown }
s.mount("/execute", ROMRUNNER)
s.mount("/kill", ROMKILLER)
s.mount("/roms", ROMFILEZ, "RomBINS")
s.mount("/", ROMS)
s.start

