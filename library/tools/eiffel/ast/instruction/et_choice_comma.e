indexing

	description:

		"Eiffel inspect choices followed by a comma"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2002, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_CHOICE_COMMA

inherit

	ET_CHOICE_ITEM

creation

	make

feature {NONE} -- Initialization

	make (a_choice: like choice; a_comma: like comma) is
			-- Create a new choice-comma.
		require
			a_choice_not_void: a_choice /= Void
			a_comma_not_void: a_comma /= Void
		do
			choice := a_choice
			comma := a_comma
		ensure
			choice_set: choice = a_choice
			comma_set: comma = a_comma
		end

feature -- Access

	choice: ET_CHOICE
			-- Choice in comma-separated list

	comma: ET_SYMBOL
			-- Comma separator

	position: ET_POSITION is
			-- Position of first character of
			-- current node in source code
		do
			Result := choice.position
		end

	break: ET_BREAK is
			-- Break which appears just after current node
		do
			Result := comma.break
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_choice_comma (Current)
		end

invariant

	comma_not_void: comma /= Void

end
