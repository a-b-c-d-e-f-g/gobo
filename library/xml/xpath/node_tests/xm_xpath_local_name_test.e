indexing

	description:

		"Objects that test for a node with a given local-name"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_LOCAL_NAME_TEST

inherit

	XM_XPATH_NODE_TEST
		redefine
			node_kind
		end
	
	XM_XPATH_SHARED_NAME_POOL

	XM_UNICODE_CHARACTERS_1_1

	KL_IMPORTED_STRING_ROUTINES

	KL_IMPORTED_INTEGER_ROUTINES

creation

	make

feature {NONE} -- Initialization

	make (a_node_type: INTEGER; a_local_name, an_original_text: STRING) is
		require
			valid_node_type: is_node_type (a_node_type)
			valid_local_name: a_local_name /= Void and then is_ncname (a_local_name)
			original_text_not_void: an_original_text /= Void
		do
			node_kind := a_node_type
			local_name := a_local_name
			original_text := an_original_text
		ensure
			node_kind_set: node_kind = a_node_type
			local_name_set: local_name = a_local_name
			original_text_set: original_text = an_original_text
		end

feature -- Access

	node_kind: INTEGER
			-- Type of nodes to which this pattern applies

	node_kind_mask: INTEGER is
			-- Mask of types of nodes matched
		do
			Result := INTEGER_.bit_shift_left (1, node_kind)
		end

feature -- Status report

	allows_text_nodes: BOOLEAN is
			-- Does this node test allow text nodes?
		do
			Result := False
		end
	
feature -- Matching

	matches_node (a_node_kind: INTEGER; a_name_code: INTEGER; a_node_type: INTEGER): BOOLEAN is
			-- Is this node test satisfied by a given node?
		do
			if a_name_code = -1 then
				Result := False
			elseif node_kind /= a_node_kind then
				Result := False
			else
				Result := STRING_.same_string (local_name, shared_name_pool.local_name_from_name_code (a_name_code))
			end
		end

feature {NONE} -- Implementation

	local_name: STRING
			-- Local name (NCName)

invariant

	valid_local_name: local_name /= Void and then is_ncname (local_name)

end
