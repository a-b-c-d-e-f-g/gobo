indexing

	description:

		"Objects that implement XPath's NameTest production"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_NAME_TEST

inherit

	XM_XPATH_NODE_TEST
		redefine
			fingerprint, node_kind, constraining_node_names
		end

	KL_IMPORTED_INTEGER_ROUTINES

creation

	make, make_same_type

feature {NONE} -- Initialization

	make (a_node_type: INTEGER; a_name_code: INTEGER; an_original_text: STRING) is
		require
			valid_node_type: is_node_type (a_node_type)
			positive_name_code: a_name_code >= 0
			original_text_not_void: an_original_text /= Void
		local
			top_bits: INTEGER
		do
			node_kind := a_node_type
			
			--	fingerprint := a_name_code & 0x0fffff
			
			top_bits := (a_name_code // bits_20) * bits_20
			fingerprint  := a_name_code - top_bits
			original_text := an_original_text
		ensure
			node_kind_set: node_kind = a_node_type
			original_text_set: original_text = an_original_text
		end

	make_same_type (a_node: XM_XPATH_NODE) is
		require
			node_not_void: a_node /= Void
		do
			node_kind := a_node.node_type
			fingerprint := a_node.fingerprint
		ensure
			same_type: node_kind = a_node.node_type
			same_fingerprint: fingerprint = a_node.fingerprint
		end

feature -- Access

	fingerprint: INTEGER
			-- Determine the name fingerprint of nodes to which this pattern applies;
			-- Used for optimisation.

	node_kind: INTEGER
			-- Type of nodes matched

	node_kind_mask: INTEGER is
			-- Mask of types of nodes matched
		do
			Result := INTEGER_.bit_shift_left (1, node_kind)
		end

	constraining_node_names: DS_SET [INTEGER] is
			-- Set of fingerprints of node names allowed
		do
			create {DS_HASH_SET [INTEGER]} Result.make (1)
			Result.put (fingerprint)
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
		local
			a_fingerprint: INTEGER
			top_bits: INTEGER
		do
			top_bits := (a_name_code // bits_20) * bits_20
			a_fingerprint := a_name_code - top_bits

			-- The next line is in this order for speed - the first test usually fails

			Result := a_fingerprint = fingerprint or else a_node_type = node_kind 
		end

feature {NONE} -- Implementation

	bits_20: INTEGER is 1048576
			-- Bit mask for 20-bit number

end
