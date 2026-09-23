local p = {}

function p.main(frame)
	local args = frame:getParent().args
	return p._main(args)
end

function p._main(args)
	return "hello from module"
end

function p.inputs(frame)
	local args = frame:getParent().args
	local listOpts
	if args and args.HunterLevel_Input and args.HunterLevel_Input > 88 then
		listOpts = "Test one,Test two"
	else
		listOpts = "Test one,Test two,Test three"
	end
	local inputs = [[
	template = /Template
	form = typein
	result = tableout
	param = playername|Name||hs|HunterLevel_Input,22,1
	param = HunterLevel_Input|Hunter Level|46|int|46-99
	param = test|Test|None|select|]] .. listOpts .. [[
	autosubmit = enabled
	]]
	return inputs
end
return p