local p = {}

local Card =
	require("Module:Sandbox/User:Alder/Card")

function p.main()
	local cards = {}

	table.insert(
		cards,
		Card.render_card{
			name = "Black cape",
			examine = "A thick, heavy black cape.",
			members = "No",
			tradeable = "Yes",
			quest = "No",
		}
	)

	table.insert(
		cards,
		Card.render_card{
			name = "Dragon scimitar",
			examine = "A vicious, curved sword.",
			members = "Yes",
			tradeable = "Yes",
			quest = "[[Monkey Madness I]]",
		}
	)

	table.insert(
		cards,
		Card.render_card{
			name = "Weapon store key",
			examine = "A key to the weapon store.",
			members = "Yes",
			tradeable = "No",
			quest = "[[Shield of Arrav]],[[Heroes' Quest]]",
		}
	)

	return '<div style="display:flex;flex-wrap:wrap;align-items:stretch;">'
		.. table.concat(cards)
		.. "</div>"
end

return p