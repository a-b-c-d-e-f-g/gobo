indexing

	description:

		"xsl:call-template element nodes"

	library: "Gobo Eiffel XSLT Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XSLT_CALL_TEMPLATE

inherit

	XM_XSLT_STYLE_ELEMENT
		redefine
			make_style_element, validate, post_validate, returned_item_type,
			mark_tail_calls, set_additional_trace_properties
		end

creation {XM_XSLT_NODE_FACTORY}

	make_style_element

feature {NONE} -- Initialization
	
	make_style_element (an_error_listener: XM_XSLT_ERROR_LISTENER; a_document: XM_XPATH_TREE_DOCUMENT;  a_parent: XM_XPATH_TREE_COMPOSITE_NODE;
		an_attribute_collection: XM_XPATH_ATTRIBUTE_COLLECTION; a_namespace_list:  DS_ARRAYED_LIST [INTEGER];
		a_name_code: INTEGER; a_sequence_number: INTEGER) is
			-- Establish invariant.
		do
			is_instruction := True
			Precursor (an_error_listener, a_document, a_parent, an_attribute_collection, a_namespace_list, a_name_code, a_sequence_number)
		end

feature -- Status setting

	mark_tail_calls is
			-- Mark tail-recursive calls on templates and functions.
		do
			use_tail_recursion := True
		end

feature -- Element change

	prepare_attributes is
			-- Set the attribute list for the element.
		local
			a_cursor: DS_ARRAYED_LIST_CURSOR [INTEGER]
			a_name_code: INTEGER
			an_expanded_name, a_name_attribute: STRING
			an_error: XM_XPATH_ERROR_VALUE
		do
			from
				a_cursor := attribute_collection.name_code_cursor
				a_cursor.start
			variant
				attribute_collection.number_of_attributes + 1 - a_cursor.index				
			until
				a_cursor.after
			loop
				a_name_code := a_cursor.item
				an_expanded_name := shared_name_pool.expanded_name_from_name_code (a_name_code)
				if STRING_.same_string (an_expanded_name, Name_attribute) then
					a_name_attribute := attribute_value_by_index (a_cursor.index)
					STRING_.left_adjust (a_name_attribute)
					STRING_.right_adjust (a_name_attribute)
				else
					check_unknown_attribute (a_name_code)
				end
				a_cursor.forth
			end
			if a_name_attribute = Void then
				report_absence ("name")
			else
				called_template_name := a_name_attribute
				if is_qname (a_name_attribute) then
					generate_name_code (a_name_attribute)
					if last_generated_name_code = -1 then
						report_compile_error (name_code_error_value)
					end
					called_template_fingerprint := fingerprint_from_name_code (last_generated_name_code)
				else
					create an_error.make_from_string (STRING_.concat ("Name attribute of xsl:call-template must be a QName. Found: ", a_name_attribute), "", "XT0290", Static_error)
					report_compile_error (an_error)
				end
			end
			attributes_prepared := True
		end

	validate is
			-- Check that the stylesheet element is valid.
			-- This is called once for each element, after the entire tree has been built.
			-- As well as validation, it can perform first-time initialisation.
		do
			check_within_template
			check_only_with_parameter_content
			find_template
			validated := True
		end

	post_validate is
			-- Hook to allow additional validation of a parent element
			--  immediately after its children have been validated.
		local
			a_declared_parameter_iterator, an_actual_parameter_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_NODE]
			a_param: XM_XSLT_PARAM
			a_with_param: XM_XSLT_WITH_PARAM
			is_parameter_ok: BOOLEAN
			a_message: STRING
			an_error: XM_XPATH_ERROR_VALUE
		do

			-- check that a parameter is supplied for each required parameter of the called template

			if template /= Void then -- should this be replaced by a pre-condition: not `any_compile_errors'?
				from
					a_declared_parameter_iterator := template.new_axis_iterator (Child_axis)
					a_declared_parameter_iterator.start
				until
					any_compile_errors or else a_declared_parameter_iterator.after
				loop
					a_param ?= a_declared_parameter_iterator.item
					if a_param /= Void and then a_param.is_required_parameter then
						from
							is_parameter_ok := False
							an_actual_parameter_iterator := new_axis_iterator (Child_axis)
							an_actual_parameter_iterator.start
						until
							is_parameter_ok or else an_actual_parameter_iterator.after
						loop
							a_with_param ?= an_actual_parameter_iterator.item
							if a_with_param /= Void and then a_with_param.variable_fingerprint = a_param.variable_fingerprint then
								is_parameter_ok := True
							end
							an_actual_parameter_iterator.forth
						end
						if not is_parameter_ok then
							create an_error.make_from_string (STRING_.concat ("No value supplied for required parameter ", a_param.variable_name), "", "XT0690", Static_error)
							report_compile_error (an_error)
						end
					end
					a_declared_parameter_iterator.forth
				end
			end

			-- Check that every supplied parameter is declared in the called template

			if not any_compile_errors then
				from
					an_actual_parameter_iterator := new_axis_iterator (Child_axis)
					an_actual_parameter_iterator.start
				until
					any_compile_errors or else an_actual_parameter_iterator.after
				loop
					a_with_param ?= an_actual_parameter_iterator.item
					if a_with_param /= Void then
						from
							a_declared_parameter_iterator := template.new_axis_iterator (Child_axis)
							a_declared_parameter_iterator.start
							is_parameter_ok := False
						until
							is_parameter_ok or else a_declared_parameter_iterator.after
						loop
							a_param ?= a_declared_parameter_iterator.item
							if a_param /= Void and then a_with_param.variable_fingerprint = a_param.variable_fingerprint then
								is_parameter_ok := True
								if a_param.as_type /= Void then
									a_with_param.check_against_required_type (a_param.as_type)
								end
							end
							a_declared_parameter_iterator.forth
						end
						if not is_parameter_ok and then not is_backwards_compatible_processing_enabled then
							a_message := STRING_.concat ("Parameter ", a_with_param.variable_name)
							a_message := STRING_.appended_string (a_message, " is not declared in the called template")
							create an_error.make_from_string (a_message, "", "XT0680", Static_error)
							report_compile_error (an_error)

						end
					end
					an_actual_parameter_iterator.forth
				end
			end
			post_validated := True
		end

	compile (an_executable: XM_XSLT_EXECUTABLE) is
			-- Compile `Current' to an excutable instruction.
		local
			a_call: XM_XSLT_COMPILED_CALL
			a_target: XM_XSLT_COMPILED_TEMPLATE
		do
			a_target := template.compiled_template
			create a_call.make (an_executable, a_target, with_param_instructions (an_executable, False), with_param_instructions (an_executable, True), use_tail_recursion)
			last_generated_expression := a_call
		end

	set_additional_trace_properties (a_trace_instruction: XM_XSLT_TRACE_INSTRUCTION) is
			-- Set additional properties on `a_trace_instruction'.
		do
			if template /= Void then
				a_trace_instruction.add_property (called_template_name, "name")
			end
		end
		
feature {XM_XSLT_STYLE_ELEMENT} -- Restricted

	returned_item_type: XM_XPATH_ITEM_TYPE is
			-- Type of item returned by this instruction
		do
			if template = Void then
				Result := any_item
			else
				Result := template.returned_item_type
			end
		end

feature {NONE} -- Implementation

	template: XM_XSLT_TEMPLATE
			-- Containing template

	use_tail_recursion: BOOLEAN
			-- Use tail recursion

	called_template_name: STRING
			-- Name of called template (for diagnostics)

	called_template_fingerprint: INTEGER
			-- Fingerprint of named template to call

	find_template is
			-- Find `template' from `called_template_fingerprint'.
		require
			attributes_prepared: attributes_prepared
		local
			a_stylesheet: XM_XSLT_STYLESHEET
			an_element_list: DS_BILINKED_LIST [XM_XSLT_STYLE_ELEMENT]
			a_cursor: DS_BILINKED_LIST_CURSOR [XM_XSLT_STYLE_ELEMENT]
			a_template: XM_XSLT_TEMPLATE
			an_error: XM_XPATH_ERROR_VALUE
		do
			a_stylesheet := principal_stylesheet
			an_element_list := a_stylesheet.top_level_elements

			-- Search for a matching template name, starting at the end in case of duplicates.
			-- This also ensures we get the one with highest import precedence.

			from
				a_cursor := an_element_list.new_cursor
				a_cursor.finish
			variant
				a_cursor.index
			until
				a_cursor.before
			loop
				a_template ?= a_cursor.item
				if a_template /= Void and then a_template.template_fingerprint = called_template_fingerprint then
					template := a_template
					a_cursor.go_before
				else
					a_cursor.back
				end
			end
			if template = Void then
				create an_error.make_from_string (STRING_.concat ("No template exists named ", called_template_name), "", "XT0650", Static_error)
				report_compile_error (an_error)
			end
		end

invariant

	instruction: is_instruction = True

end
