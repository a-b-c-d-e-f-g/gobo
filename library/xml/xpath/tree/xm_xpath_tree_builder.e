indexing
	description:

		"Callbacks filter producing standard trees"

	library: "Gobo Eiffel XML Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_TREE_BUILDER

inherit

	XM_XPATH_RECEIVER

	XM_XPATH_TYPE

	XM_XPATH_SHARED_CONFORMANCE

	XM_XPATH_STANDARD_NAMESPACES

	KL_IMPORTED_STRING_ROUTINES

creation

	make

feature {NONE} -- Initialization

	make (a_name_pool: XM_XPATH_NAME_POOL; a_node_factory: XM_XPATH_NODE_FACTORY) is
			-- Set name pool and node factory..
		require
			name_pool_not_void: a_name_pool /= Void
			node_factory_not_void: a_node_factory /= void
		do
			name_pool := a_name_pool
			system_id := ""
			node_factory := a_node_factory
		ensure
			name_pool_set: name_pool = a_name_pool
			node_factory_set: node_factory = a_node_factory
		end

feature -- Access


	document: XM_XPATH_TREE_DOCUMENT
			-- Resulting document

	system_id: STRING
			-- The SYSTEM id of the document being processed

feature -- Status report

	has_error: BOOLEAN
			-- Has an error occurred?

	last_error: STRING
			-- Error message

feature -- Events

	on_error (a_message: STRING) is
			-- Event producer detected an error.
		do
			has_error := True
			last_error := a_message
		end

	start_document is
			-- Notify the start of the document
		do
			has_error := False
			last_error := Void

			-- TODO add timing information

			create document.make (name_pool, system_id)
			current_depth := 1
			next_node_number := 2
			current_composite_node := document
		end

	set_unparsed_entity (a_name: STRING; a_system_id: STRING; a_public_id: STRING) is
			-- Notify an unparsed entity URI
		do
			if not has_error then
				-- TODO document.set_unparsed_entity (a_name, a_system_id, a_public_id)
			end
		end

	start_element (a_name_code: INTEGER; a_type_code: INTEGER; properties: INTEGER) is
			-- Notify the start of an element
		local
			an_element: XM_XPATH_TREE_ELEMENT
		do
			if not has_error then
				pending_element_name_code := a_name_code
			end
		end

	notify_namespace (a_namespace_code: INTEGER; properties: INTEGER) is
			-- Notify a namespace.
		do
			if not has_error then
				if pending_namespaces = Void then
					create pending_namespaces.make (5)
				elseif not pending_namespaces.extendible (1) then
					pending_namespaces.resize (2 * pending_namespaces.count)
				end
				pending_namespaces.put_last (a_namespace_code)
			end
		end

	notify_attribute (a_name_code: INTEGER; a_type_code: INTEGER; a_value: STRING; properties: INTEGER) is
			-- Notify an attribute.
		local
			a_new_type_code: like a_type_code
			new_size: INTEGER
		do
			if not has_error then
				a_new_type_code := a_type_code
				if conformance.basic_xslt_processor then
					a_new_type_code := Untyped_atomic_type_code
				else
						check
							Only_basic_xslt_processors_are_supported: False
						end
				end
				if pending_attributes = Void then
					create pending_attributes.make (name_pool)
				end
				pending_attributes.add_attribute (a_name_code, a_new_type_code, a_value)
			end
		end

	start_content is
			-- Notify the start of the content, that is, the completion of all attributes and namespaces.
		local
			an_element: XM_XPATH_TREE_ELEMENT
			a_cursor: DS_ARRAYED_LIST_CURSOR [INTEGER]
			a_counter: INTEGER
		do
			if not has_error then
				an_element := node_factory.new_element_node (document, current_composite_node, pending_attributes, pending_namespaces, pending_element_name_code, next_node_number)
				if an_element.is_error then
					has_error := True
					last_error := an_element.error_value.error_message
				else
					next_node_number := next_node_number + 1
					current_depth := current_depth + 1
					if current_composite_node = document then
						document.set_document_element (an_element)
					end
					current_composite_node := an_element
				end
			end
			pending_namespaces := Void
			pending_attributes := Void
		end

	end_element is
			-- Notify the end of an element.
		do
			if not has_error then
				current_depth := current_depth - 1
				current_composite_node := current_composite_node.parent
			end
		end

	notify_characters (a_character_string: STRING; properties: INTEGER) is
			-- Notify character data.
		local
			a_text_node: XM_XPATH_TREE_TEXT
		do
			if not has_error then
				if a_character_string.count > 0 then
					create a_text_node.make (document, a_character_string)
					current_composite_node.add_child (a_text_node)
				end
			end
		end

	notify_processing_instruction (a_target: STRING; a_data_string: STRING; properties: INTEGER) is
			-- Notify a processing instruction.
		local
			a_processing_instruction: XM_XPATH_TREE_PROCESSING_INSTRUCTION
			a_name_code: INTEGER
		do
			if not has_error then
				if not name_pool.is_name_code_allocated ("", "", a_target) then
					
					-- TODO need to check for resource exhaustion in name pool
					
					name_pool.allocate_name ("", "", a_target)
					a_name_code := name_pool.last_name_code
				else
					a_name_code := name_pool.name_code ("", "", a_target) 
				end
				create a_processing_instruction.make (document, a_name_code, a_data_string)
				current_composite_node.add_child (a_processing_instruction)
				
				-- TODO: locator info
				
			end
		end

	notify_comment (a_content_string: STRING; properties: INTEGER) is
			-- Notify a comment.
		local
			a_comment: XM_XPATH_TREE_COMMENT
		do
			if not has_error then
				create a_comment.make (document, a_content_string)
				current_composite_node.add_child (a_comment)
			end
		end

	end_document is
			-- Parsing finished.
		do
			
			-- TODO compact tree
			-- TODO add timing information

			current_composite_node := Void
			node_factory := Void
		end

feature -- Element change

	set_system_id (a_system_id: STRING) is
			-- Set the system-id of the destination tree
		do
			system_id := a_system_id
		end

feature {NONE} -- Implementation

	node_factory: XM_XPATH_NODE_FACTORY
			-- Node factory

	current_depth: INTEGER
			-- Depth within the tree

	next_node_number: INTEGER
			-- Node number for next node to be created

	current_composite_node: XM_XPATH_TREE_COMPOSITE_NODE
			-- Current document or element node

	pending_namespaces: DS_ARRAYED_LIST [INTEGER]
			-- Name codes of namespaces defined on the current element

			-- The next three lists together form a list of triples

	pending_attributes: XM_XPATH_ATTRIBUTE_COLLECTION
			-- Pending attributes

	pending_element_name_code: INTEGER
			-- Name code for pending element

invariant

	last_error_not_void: has_error implies last_error /= Void

end
	