indexing

	description:

		"Objects that provide a context for parsing an expression appearing in a context other than a stylesheet"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_STAND_ALONE_CONTEXT

inherit

	XM_XPATH_STATIC_CONTEXT

	XM_XPATH_STANDARD_NAMESPACES

	XM_XPATH_SHARED_FUNCTION_FACTORY

	KL_SHARED_STANDARD_FILES

	KL_IMPORTED_STRING_ROUTINES

creation

	make, make_upon_node

feature {NONE} -- Initialization

	make (a_name_pool: XM_XPATH_NAME_POOL; warnings: BOOLEAN; backwards: BOOLEAN) is
			-- Establish invariant.
		require
			name_pool_not_void: a_name_pool /= Void
			warnings_implies_backwards_compatibility: warnings implies backwards
		local
			a_code_point_collator: ST_COLLATOR
		do
			name_pool := a_name_pool
			create collations.make (10)
			create variables.make (10)
			create a_code_point_collator
			declare_collation ("http://www.w3.org/2003/11/xpath-functions/collation/codepoint", a_code_point_collator, True)
			clear_namespaces
			warnings_to_std_error := warnings
			is_backwards_compatible_mode := backwards
		ensure
			name_pool_set: name_pool = a_name_pool
			warnings_set: warnings_to_std_error = warnings
			backward_compatibility: is_backwards_compatible_mode = backwards
		end

	make_upon_node is
			-- TODO
		do
			print ("{XM_XPATH_STAND_ALONE_CONTEXT}.make_upon_node not implemented!%N")
		end

feature -- Access

	default_element_namespace: INTEGER is
			-- Default XPath namespace, as a namespace code that can be looked up in `name_pool'
		do
			Result := namespace_index_to_uri_code (Null_prefix_index)
		end

	namespaces: DS_HASH_TABLE [STRING, STRING]
			-- Maps prefixes to URIs

	warnings_to_std_error: BOOLEAN
			-- should warning messages be sent to standard error stream?
	
	default_collation_name: STRING
			-- URI naming the default collation

	collator (a_collation_name: STRING): ST_COLLATOR is
			-- Collation named `a_collation_name'
		do
			if collations.has (a_collation_name) then
				Result := collations.item (a_collation_name)
			end
		end

	uri_for_prefix (an_xml_prefix: STRING): STRING is
			-- URI for a namespace prefix;
			-- The default namespace is NOT used when the prefix is empty.
		do
			Result := namespaces.item (an_xml_prefix)
		end

		is_backwards_compatible_mode: BOOLEAN
			-- Is Backwards Compatible Mode used?

feature -- Status report

	is_prefix_declared (an_xml_prefix: STRING): BOOLEAN is
			-- Is `an_xml_prefix' allocated to a namespace?
		do
			Result := namespaces.has (an_xml_prefix)
		end

	is_variable_declared (a_fingerprint: INTEGER): BOOLEAN is
			-- Does `a_fingerprint' represent a variable declared in the static context?
		do
			Result := variables.has (a_fingerprint)
		end

	is_qname_variable_declared (a_qname: STRING): BOOLEAN is
			-- Does `a_qname' represent a variable declared in the static context?
		require
			valid_name: a_qname /= Void and then is_qname (a_qname)
		local
			a_fingerprint: INTEGER
		do
			a_fingerprint := qname_to_fingerprint (a_qname)
			if a_fingerprint = -1 then
				Result := False
			else
				Result := is_variable_declared (a_fingerprint)
			end
		end

feature -- Element change

	declare_collation (a_name: STRING; a_collator: ST_COLLATOR; is_default_collation: BOOLEAN) is
			-- Declare a collation.
		require
			collation_name_not_void: a_name /= Void -- TODO and then is a URI
			collator_not_void: a_collator /= Void
		do
			if collations.has (a_name) then
				collations.replace (a_collator, a_name)
			else
				if collations.is_full then
					collations.resize (2 * collations.count)
				end
				collations.put (a_collator, a_name)
			end
			if is_default_collation then
				default_collation_name := a_name
			end
		ensure
			collator_declared: collations.has (a_name) and then collations.item (a_name) = a_collator
			default_collator: is_default_collation implies STRING_.same_string (a_name, default_collation_name)
		end

	declare_namespace (an_xml_prefix, a_uri: STRING) is
		require
			prefix_not_void: an_xml_prefix /= Void
			uri_not_void: a_uri /= Void
			not_declared: not namespaces.has (an_xml_prefix)
		do
			namespaces.put (a_uri, an_xml_prefix)
		ensure
			set: namespaces.has (an_xml_prefix) and then STRING_.same_string (a_uri, namespaces.item (an_xml_prefix))
		end

	declare_variable (a_qname: STRING; an_initial_value: XM_XPATH_VALUE) is
			-- Declare `a_qname' as a variable.
		require
			valid_name: a_qname /= Void and then is_qname (a_qname)
			variable_not_declared: not is_qname_variable_declared (a_qname)
			-- N.B. if `a_qname' is a qualified name, then the prefix
			--  must have been declared using `declare_namespace'.
		local
			a_variable: XM_XPATH_VARIABLE
			a_fingerprint: INTEGER
		do
			a_fingerprint := qname_to_fingerprint (a_qname)
			if a_fingerprint = -1 then
				do_nothing

				-- TODO - how to get allocation faliure message, and raise a dynamic error?
				--  We will get a post-condition failed exception. Not good enough
				
			else
				create a_variable.make (a_qname, an_initial_value)
				variables.put (a_variable, a_fingerprint)
			end
		ensure
			variable_declared: is_qname_variable_declared (a_qname)
		end

	clear_namespaces is
			-- Clear all the declared namespaces, except for the standard ones.
		do
			create namespaces.make (10)
			declare_namespace ("xml", Xml_uri)
			declare_namespace ("xsl", Xslt_uri)
			declare_namespace ("xs", Xml_schema_uri)
			declare_namespace ("", Null_uri)
		end

	bind_variable (a_fingerprint: INTEGER) is
			-- Bind variable to it's declaration.
		local
			var: XM_XPATH_VARIABLE
		do
			var := variables.item (a_fingerprint)
			internal_last_bound_variable := var
			-- An option to return boolean false value if not found can be provided by re-defining this routine
			--  along with `is_variable_declared' in a descendant class.
		end

	bind_function (a_qname: STRING; arguments: DS_ARRAYED_LIST [XM_XPATH_EXPRESSION]) is
			-- Identify a function appearing in an expression.
		local
			an_xml_prefix, a_uri, a_local_name: STRING
			a_fingerprint, a_name_code: INTEGER
			a_splitter: ST_SPLITTER
			name_parts: DS_LIST [STRING]
		do
			debug ("XPath stand-alone context")
				std.error.put_string ("Binding function: ")
				std.error.put_string (a_qname)
				std.error.put_new_line
			end
			if is_ncname (a_qname) then
				bind_system_function (a_qname, arguments)
			else

				-- The function QName is prefixed, but it still may be a system-function

				create a_splitter.make
				a_splitter.set_separators (":")
				name_parts := a_splitter.split (a_qname)
					check
						two_name_components: name_parts.count = 2
					end
				an_xml_prefix := name_parts.item (1)
				a_local_name := name_parts.item (2)
				if is_prefix_declared (an_xml_prefix) then
					a_uri := uri_for_prefix (an_xml_prefix)
					if name_pool.is_name_code_allocated (an_xml_prefix, a_uri, a_local_name) then
						a_name_code := name_pool.name_code (an_xml_prefix, a_uri, a_local_name)
					else
						if not name_pool.is_name_pool_full (a_uri, a_local_name) then
							name_pool.allocate_name (an_xml_prefix, a_uri, a_local_name)
							a_name_code := name_pool.last_name_code
						else
							was_last_function_bound := False
							set_bind_function_failure_message (STRING_.appended_string ("Name pool has no room to allocate ", a_qname))
						end
					end
					a_fingerprint := a_name_code // bits_20
					if STRING_.same_string (a_uri, Xpath_functions_uri) then
						bind_system_function (a_local_name, arguments)
					else

						-- A built-in extension function, or a contructor for a built-in type

						--	Now try for a constructor function for a built-in type

						-- TODO

						was_last_function_bound := False
						set_bind_function_failure_message ("Constructor functions not implemented yet.")
					end
				else
					was_last_function_bound := False
					set_bind_function_failure_message (STRING_.appended_string (an_xml_prefix, " is not an in-scope XML prefix."))
				end
			end
		end


feature -- Output

	issue_warning (a_warning: STRING) is
			-- Issue a warning message
		do
			if warnings_to_std_error then
				std.error.put_string (a_warning)
				std.error.put_new_line
			end
		end

feature {NONE} -- Implementation

	variables:  DS_HASH_TABLE [XM_XPATH_VARIABLE, INTEGER]
			-- Variable-bindings

	collations: DS_HASH_TABLE [ST_COLLATOR, STRING]
			-- Named collations

	bind_system_function (a_name: STRING; arguments: DS_ARRAYED_LIST [XM_XPATH_EXPRESSION]) is
			-- Identify a system function appearing in an expression.
		require
			valid_qname: a_name /= Void and then is_qname (a_name)
			arguments_not_void: arguments /= Void
		local
			a_function_call: XM_XPATH_FUNCTION_CALL
		do
			-- TODO - need a system function factory
			a_function_call := Function_factory.make_system_function (a_name)
			if a_function_call = Void then
				was_last_function_bound := False
				set_bind_function_failure_message (STRING_.appended_string ("Unknown system function: ", a_name))
			else
				was_last_function_bound := True
				a_function_call.set_arguments (arguments)
				set_last_bound_function (a_function_call)
			end
		ensure
			function_bound: was_last_function_bound implies last_bound_function /= Void
		end

	bits_20: INTEGER is 1048576 
			-- 0x0fffff

	qname_to_fingerprint (a_qname: STRING): INTEGER is
		require
			valid_name: a_qname /= Void and then is_qname (a_qname)
		local
			an_xml_prefix, a_local_name, a_uri, a_message: STRING
			a_splitter: ST_SPLITTER
			parts: DS_LIST [STRING]
			a_name_code: INTEGER
		do
			create a_splitter.make
			a_splitter.set_separators (":")
			parts := a_splitter.split (a_qname)
			if parts.count = 1 then
				an_xml_prefix := ""
				a_uri := ""
				a_local_name := parts.item (1)
			else
				an_xml_prefix := parts.item (1)
				a_local_name := parts.item (2)
				a_uri := uri_for_prefix (an_xml_prefix)
			end
			if name_pool.is_name_code_allocated (an_xml_prefix, a_uri, a_local_name) then
				a_name_code := name_pool.name_code (an_xml_prefix, a_uri, a_local_name)
			else
				if not name_pool.is_name_pool_full (a_uri, a_local_name) then
					name_pool.allocate_name (an_xml_prefix, a_uri, a_local_name)
					a_name_code := name_pool.last_name_code
				else
					Result := -1
				end
			end
			Result := a_name_code \\ bits_20
		ensure
			nearly_positive_fingerprint: Result >= -1
		end
	
invariant

	namespaces /= Void
	default_collation_name: default_collation_name /= Void
	collations: collations /= Void
	variables: variables /= Void
	warnings_implies_backwards_compatibility: warnings_to_std_error implies is_backwards_compatible_mode

end
