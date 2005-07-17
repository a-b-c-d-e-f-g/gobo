indexing

	description:

		"Eiffel assigners"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2005, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_ASSIGNER

inherit

	ET_AST_NODE

create

	make

feature {NONE} -- Initialization

	make (a_name: like feature_name) is
			-- Create a new assign-feature_name pair.
		require
			a_name_not_void: a_name /= Void
		do
			feature_name := a_name
			assign_keyword := tokens.assign_keyword
		ensure
			feature_name_set: feature_name = a_name
		end

feature -- Initialization

	reset is
			-- Reset feature name as it was when it was first parsed.
		do
			feature_name.reset
		end

feature -- Access

	feature_name: ET_FEATURE_NAME
			-- Feature name

	assign_keyword: ET_KEYWORD
			-- 'assign' keyword

	position: ET_POSITION is
			-- Position of first character of
			-- current node in source code
		do
			Result := assign_keyword.position
			if Result.is_null then
				Result := feature_name.position
			end
		end

	first_leaf: ET_AST_LEAF is
			-- First leaf node in current node
		do
			Result := assign_keyword
		end

	last_leaf: ET_AST_LEAF is
			-- Last leaf node in current node
		do
			Result := feature_name.last_leaf
		end

	break: ET_BREAK is
			-- Break which appears just after current node
		do
			Result := feature_name.break
		end

feature -- Setting

	set_assign_keyword (a_keyword: like assign_keyword) is
			-- Set `a_keyword' to `assign_keyword'.
		require
			a_keyword_not_void: a_keyword /= Void
		do
			assign_keyword := a_keyword
		ensure
			assign_keyword_set: assign_keyword = a_keyword
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_assigner (Current)
		end

invariant

	feature_name_not_void: feature_name /= Void
	assign_keyword_not_void: assign_keyword /= Void

end
