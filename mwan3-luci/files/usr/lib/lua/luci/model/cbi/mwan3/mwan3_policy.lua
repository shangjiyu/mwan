local ds = require "luci.dispatcher"

function policywarn()
	local warns = ""
	local polnum = 0
	uci.cursor():foreach("mwan3", "policy",
		function ()
			polnum = polnum+1
		end
	)
	if polnum <= 84 then
		warns = "<strong><em>There are currently " .. polnum .. " of 84 supported policies configured!</em></strong>"
	else
		warns = "<font color=\"ff0000\"><strong><em>WARNING: " .. polnum .. " policies are configured exceeding the maximum of 84!</em></strong></font>"
	end
	return warns
end

-- ------ policy configuration ------ --

m5 = Map("mwan3", translate("MWAN3 Multi-WAN Policy Configuration"),
	translate(policywarn()))


mwan_policy = m5:section(TypedSection, "policy", translate("Policies"),
	translate("MWAN3 supports up to 84 policies<br />") ..
	translate("Name may contain characters A-Z, a-z, 0-9, _ and no spaces<br />") ..
	translate("Policies may not share the same name as configured interfaces, members or rules"))
	mwan_policy.addremove = true
	mwan_policy.dynamic = false
	mwan_policy.sortable = false
	mwan_policy.template = "cbi/tblsection"
	mwan_policy.extedit = ds.build_url("admin", "network", "mwan3", "policy", "%s")

	function mwan_policy.create(self, section)
		TypedSection.create(self, section)
		m5.uci:save("mwan3")
		luci.http.redirect(ds.build_url("admin", "network", "mwan3", "policy", section))
	end


use_member = mwan_policy:option(DummyValue, "use_member", translate("Members assigned"))
	use_member.rawhtml = true
	function use_member.cfgvalue(self, s)
		local str = "<br />"
		local tab = self.map:get(s, "use_member")
		if tab then
			for k,v in pairs(tab) do
				str = str .. v .. "<br />"
			end
		else
			str = "<br /><font size=\"+4\">-</font>"
		end
		str = str .. "<br />"
		return str
	end


return m5
