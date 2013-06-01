-- ------ extra functions ------ --

function trailtrim(s)
	local n = #s
	while n > 0 and s:find("^%s", n) do n = n - 1 end
	return s:sub(1, n)
end

-- ------ hotplug script configuration ------ --

fs = require "nixio.fs"
hpscript = "/etc/hotplug.d/iface/16-mwan3custom"
defscript = table.concat{"#!/bin/sh\n\n## example hotplug script\n\n#case \"$ACTION\" in\n",
"#	ifup)\n#		# run this code/script/function\n#		# if an ",
"interface comes online\n#\n#		# if you want to limit it to certain interfaces you ",
"can do\n#		if [ \"$INTERFACE\" == \"wan1\" ]; then\n#			# ",
"run this code\n#		fi\n#	;;\n#\n#	ifdown)\n#		# run this ",
"code/script/function\n#		# if an interface goes offline\n#	;;\n#esac\n"}


f = SimpleForm("mwanhotplug", translate("Custom Hotplug Script Configuration"),
	translate("This section allows you to modify the contents of /etc/hotplug.d/iface/16-mwan3custom<br />") ..
	translate("This is useful for running system commands and/or scripts based on interface ifup or ifdown hotplug events<br /><br />") ..
	translate("Notes:<br />") ..
	translate("The first line of the script must be &#34;#!/bin/sh&#34; without quotes<br />") ..
	translate("Lines beginning with # are comments and are not executed<br />") ..
	translate("To restore the default script simply erase the contents of the box and click Submit<br /><br />") ..
	translate("Available variables:<br />") ..
	translate("$ACTION is the hotplug event (ifup, ifdown)<br />") ..
	translate("$INTERFACE is the interface name (wan1, wan2, etc.)<br />") ..
	translate("$DEVICE is the device name attached to the interface (eth0.1, eth1, etc.)"))


t = f:field(TextValue, "mwhp")
t.rmempty = true
t.rows = 20
function t.cfgvalue()
	local hps = fs.readfile(hpscript)
	if not hps or hps == "" then -- if script does not exist or is blank create default
		fs.writefile(hpscript, defscript)
		return fs.readfile(hpscript)
	else
		return hps
	end
end

function f.handle(self, state, data)
	if state == FORM_VALID then
		if data.mwhp then -- write existing or new contents to hpscript
			fs.writefile(hpscript, trailtrim(data.mwhp:gsub("\r\n", "\n")) .. "\n")
		else -- if user erases all contents restore default hotplug script
			fs.writefile(hpscript, defscript)
		end
	end
end


return f