indexing

	description:

		"Names of Eiffel infix '/' features"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2002, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_INFIX_DIVIDE_NAME

inherit

	ET_INFIX_DIVIDE

	ET_INFIX_NAME
		undefine
			is_infix_divide
		end

creation

	make

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_infix_divide_name (Current)
		end

end
