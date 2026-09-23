local p = {}

function p.getCount(frame)
	return mw.site.stats.usersInGroup(frame.args[1])
end

return p