indexing

	description:

		"XPath nodes"

	library: "Gobo Eiffel XML Library"
	copyright: "Copyright (c) 2003, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class XM_XPATH_NODE

inherit

	XM_XPATH_ITEM

	XM_XPATH_AXIS

		-- This class represents a node in gexslt's object model.
		-- It combines the features of the XPath data model, 
		--  with some of the features from the W3C's dom::Node (for convenience),
		--  along with additional features to make life easier.

feature -- Access

	node_number: INTEGER
			-- Uniquely identifies this node within the document

	document_number: INTEGER is
			-- Uniquely identifies the owning document.
		deferred
		ensure
			strictly_positive_result: Result > 0
		end

	base_uri: STRING is
			-- Base URI
		require
			not_in_error: not is_item_in_error
		deferred
		ensure
			base_uri_may_be_void: True
		end

	node_kind: STRING is
			-- Kind of node
			-- Must be one of:
			-- "document", "element", "attribute",
			-- "namespace", "processing-instruction",
			-- "comment", or "text".
		require
			not_in_error: not is_item_in_error
		deferred
		ensure
			node_kind_not_void: Result /= Void
		end

	node_name: STRING is
			-- Qualified name
		require
			not_in_error: not is_item_in_error
		deferred
		ensure
			node_name_may_be_void: True
		end

	-- TODO add type:

	parent: XM_XPATH_NODE is
			-- Parent of current node
			-- `Void' if current node is root,
			-- or for orphan nodes.
		require
			not_in_error: not is_item_in_error
		deferred
		ensure
			parent_may_be_void: True
		end
	
	root: XM_XPATH_NODE is
			-- The root node for `Current';
			-- This is not necessarily a Document node.
		require
			not_in_error: not is_item_in_error
		local
			a_parent_node: XM_XPATH_NODE
		do
			from
				Result := Current
				a_parent_node := parent
			until
				a_parent_node = Void
			loop
				Result := a_parent_node
				a_parent_node := a_parent_node.parent
			end
		ensure
			root_node_not_void: Result /= Void
		end

	type_annotation: INTEGER is
			--Type annotation of this node, if any
		require
			not_in_error: not is_item_in_error
		do
			if item_type = Element_node then
				Result := Untyped_type
			else
				Result := Untyped_atomic_type
			end
		end

	fingerprint: INTEGER is
			-- Fingerprint of this node - used in matching names
		require
			not_in_error: not is_item_in_error
		deferred
		end
	
	name_code: INTEGER is
			-- Name code this node - used in displaying names
		require
			not_in_error: not is_item_in_error
		deferred
		end
	
	document_root: XM_XPATH_DOCUMENT is
			-- The document node for `Current';
			-- If `Current' is in a document fragment, then return Void
		require
			not_in_error: not is_item_in_error
		local
			a_root: XM_XPATH_DOCUMENT
		do
			a_root ?= root
			if a_root = Void then
				debug ("XPath abstract node")
					std.error.put_string ("Document node is void%N")
				end
			else
				debug ("XPath abstract node")
					std.error.put_string ("Document node kind is ")
					std.error.put_string (a_root.node_kind)
					std.error.put_new_line
				end
			end
			if a_root /= Void and then a_root.node_kind.is_equal ("document") then
				Result := a_root
			end
		end

	first_child: XM_XPATH_NODE is
			-- The first child of this node;
			-- If there are no children, return `Void'
		require
			not_in_error: not is_item_in_error
		local
			an_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_NODE]
		do
			an_iterator := new_axis_iterator (Child_axis)
			an_iterator.start
			if not an_iterator.after then Result := an_iterator.item end
		end

	last_child: XM_XPATH_NODE is
			-- The last child of this node;
			-- If there are no children, return `Void'
		require
			not_in_error: not is_item_in_error
		local
			an_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_NODE]
		do
			an_iterator := new_axis_iterator (Child_axis)
			from
				an_iterator.start
			until
				an_iterator.after
			loop
				Result := an_iterator.item
					check
						result_not_void: Result /= Void
						-- Because not before (due to start) and not after (due to until)
					end
				an_iterator.forth
			end
		end

	previous_sibling: XM_XPATH_NODE is
			-- The previous sibling of this node;
			-- If there is no such node, return `Void'
		require
			not_in_error: not is_item_in_error
		local
			an_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_NODE]
		do
			an_iterator := new_axis_iterator (Preceding_sibling_axis)
			an_iterator.start
			if not an_iterator.after then Result := an_iterator.item end
		end
	
	next_sibling: XM_XPATH_NODE is
			-- The next sibling of this node;
			-- If there is no such node, return `Void'
		require
			not_in_error: not is_item_in_error
		local
			an_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_NODE]
		do
			an_iterator := new_axis_iterator (Following_sibling_axis)
			an_iterator.start
			if not an_iterator.after then Result := an_iterator.item end
		end
	
	document_element: XM_XPATH_ELEMENT is
			-- The top-level element;
			-- If the document is not well-formed
			-- (i.e. it is a document fragment), then
			-- return the last element child of the document root.
		require
			not_in_error: not is_item_in_error
		local
			a_root: XM_XPATH_DOCUMENT
			an_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_NODE]
			an_element_node_test: XM_XPATH_NODE_KIND_TEST
		do
			a_root := document_root
			if a_root = Void or else a_root.is_item_in_error then
				debug ("XPath abstract node")
					if a_root = Void then
						std.error.put_string ("Document root is void%N")
					else
						std.error.put_string (a_root.evaluation_error_value.error_message)
						std.error.put_new_line
					end
				end
				Result := Void
			else
				create an_element_node_test.make (Element_node)
				an_iterator := a_root.new_axis_iterator_with_node_test (Child_axis, an_element_node_test)
				debug ("XPath abstract node")
					std.error.put_string ("Document element: iterator is after? ")
					std.error.put_string (an_iterator.after.out)
					std.error.put_new_line
				end
				an_iterator.start
				Result ?= an_iterator.item
			end
		end
	
	typed_value: XM_XPATH_VALUE is
			-- Typed value
		local
			a_type: INTEGER
			a_string_value: XM_XPATH_STRING_VALUE
		do
			a_type := type_annotation
			if a_type = Untyped_atomic_type then
				create {XM_XPATH_UNTYPED_ATOMIC_VALUE} Result.make (string_value)
			elseif a_type = Untyped_type then
				create {XM_XPATH_UNTYPED_ATOMIC_VALUE} Result.make (string_value)
			else
				-- TODO complex types should be dealt with properly
				create a_string_value.make (string_value)
				-- This is wrong, as convert requires and yields an atomic type
				-- Result := a_string_value.convert (a_type)
			end
		end

	new_axis_iterator (an_axis_type: INTEGER): XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_NODE] is
			-- An enumeration over the nodes reachable by `an_axis_type' from this node
		require
			not_in_error: not is_item_in_error
			valid_axis: is_axis_valid (an_axis_type)
		deferred
		ensure
			result_not_in_error: Result /= Void and then not Result.is_error
		end

	new_axis_iterator_with_node_test (an_axis_type: INTEGER; a_node_test: XM_XPATH_NODE_TEST): XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_NODE] is
			-- An enumeration over the nodes reachable by `an_axis_type' from this node;
			-- Only nodes that match the pattern specified by `a_node_test' will be selected.
		require
			not_in_error: not is_item_in_error
			node_test_not_void: a_node_test /= Void
			valid_axis: is_axis_valid (an_axis_type)
		deferred
		ensure
			result_not_in_error: Result /= Void and then not Result.is_error
		end

feature -- Comparison

	is_same_node (other: XM_XPATH_NODE): BOOLEAN is
			-- Does `Current' represent the same node in the tree as `other'?
		require
			not_in_error: not is_item_in_error
			other_node_not_void: other /= Void
		deferred
		end

	three_way_comparison (other: XM_XPATH_NODE): INTEGER is
			-- If current object equal to other, 0;
			-- if smaller, -1; if greater, 1
		require
			other_exists: other /= Void
		deferred
		ensure
			valid_result: -1 <= Result and then Result <= 1
		end

feature -- Status report

	is_nilled: BOOLEAN is
			-- Is current node "nilled"? (i.e. xsi: nill="true")
		require
			not_in_error: not is_item_in_error
		deferred
		end

	has_child_nodes: BOOLEAN is
			-- Does `Current' have any children?
		require
			not_in_error: not is_item_in_error
		deferred
		end

feature {XM_XPATH_NODE} -- Local

	identity: INTEGER -- TODO: change to INTEGER_64 when all compilers support this
			-- Unique identifier within the document
			-- Increases with document order.
	
	is_possible_child: BOOLEAN is
			-- Can this node be a child of a document or element node?
		require
			not_in_error: not is_item_in_error
		deferred
		end

end
