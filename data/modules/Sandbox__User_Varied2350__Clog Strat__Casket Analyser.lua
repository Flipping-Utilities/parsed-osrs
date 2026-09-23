local p = {}

local clog = require('Module:Sandbox/User:Varied2350/Clog Strat/Collection log')

local defaults = {
	obtainhr = {
		beginner = 0,
		easy = 0,
		medium = 0,
		hard = 0,
		elite = 2.7,
		master = 2.7
	},
	comphr = {
		beginner = 60,
		easy = 50,
		medium = 30,
		hard = 22,
		elite = 15,
		master = 8
	},
	caskets = {
		beginner = 0,
		easy = 0,
		medium = 0,
		hard = 0,
		elite = 0,
		master = 0
	}
}

local function parse_args(args)
	local parsed_args = {}
	
	mw.logObject(args)
	
	local rsn = args['wsdata']
	local arg_groups = {"obtainhr", "comphr", "caskets"}
	local tiers = {"beginner", "easy", "medium", "hard", "elite", "master"}
	
	for _,group in ipairs(arg_groups) do
		parsed_args[group] = {}
		for _,tier in ipairs(tiers) do
			parsed_args[group][tier] = args[group..tier] or defaults[group][tier]
		end
	end
	
	local clog_data = args['wsdata-json']
	clog_data = mw.text.split(clog_data or '', ',', true)
	if not clog_data then
		error("Input value for collection log data is invalid.")
	end
	
	parsed_args['clog_data'] = {}
	for _,v in ipairs(clog_data) do
		parsed_args.clog_data[v] = {}
	end
	
	return parsed_args
end

local function build_data()
	
end

local function build_table(clog_data)
	local ret = mw.html.create('table')
		:addClass('wikitable sortable sticky-header align-center')
	
	ret:tag('tr')
		:tag('th'):wikitext('Collected IDs')
	
	for id,item_data in pairs(clog_data) do
		ret:tag('tr')
			:tag('td'):wikitext(id)
	end
	
	return ret
end


function p.main(frame)
	local args = frame:getParent().args
	return p._main(args)
end

function p._main(args)
	local parsed_args = parse_args(args)
	
	
end

return p