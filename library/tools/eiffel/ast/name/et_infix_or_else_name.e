indexing

	description:

		"Names of Eiffel infix 'or else' features"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2002, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_INFIX_OR_ELSE_NAME

inherit

	ET_INFIX_OR_ELSE

	ET_INFIX_NAME
		undefine
			is_infix_or_else
		end

creation

	make

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_infix_or_else_name (Current)
		end

end
