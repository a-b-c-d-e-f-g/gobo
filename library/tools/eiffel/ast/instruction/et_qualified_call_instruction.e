indexing

	description:

		"Eiffel qualified call instructions"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2002, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_QUALIFIED_CALL_INSTRUCTION

inherit

	ET_CALL_INSTRUCTION
		rename
			make as make_unqualified_call
		undefine
			target, position
		redefine
			process
		end

	ET_QUALIFIED_FEATURE_CALL

creation

	make

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_qualified_call_instruction (Current)
		end

end
