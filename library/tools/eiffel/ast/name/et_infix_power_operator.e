indexing

	description:

		"Eiffel binary '^' operators"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2002, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_INFIX_POWER_OPERATOR

inherit

	ET_INFIX_POWER

	ET_INFIX_SYMBOL_OPERATOR
		undefine
			is_infix_power
		end

creation

	make, make_with_position

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_infix_power_operator (Current)
		end

end
