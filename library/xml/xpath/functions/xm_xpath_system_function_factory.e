indexing

	description:

		"Objects that create XPath system functions"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_SYSTEM_FUNCTION_FACTORY

inherit

	XM_UNICODE_CHARACTERS_1_1

	KL_IMPORTED_STRING_ROUTINES

feature -- Creation
	
	make_system_function (a_function_name: STRING): XM_XPATH_SYSTEM_FUNCTION is
			--  Create an XM_XPATH_FUNCTION_CALL object for `a_function_name'
		require
			valid_function_name: a_function_name /= Void and then is_ncname (a_function_name)
		do
			if STRING_.same_string (a_function_name, "boolean") then
				create {XM_XPATH_BOOLEAN} Result.make
			elseif STRING_.same_string (a_function_name, "concat") then
				create {XM_XPATH_CONCAT} Result.make
			elseif STRING_.same_string (a_function_name, "contains") then
				create {XM_XPATH_CONTAINS} Result.make
			elseif STRING_.same_string (a_function_name, "count") then
				create {XM_XPATH_COUNT} Result.make
			elseif STRING_.same_string (a_function_name, "current-date") then
				create {XM_XPATH_CURRENT_DATE} Result.make
			elseif STRING_.same_string (a_function_name, "current-dateTime") then
				create {XM_XPATH_CURRENT_DATETIME} Result.make
			elseif STRING_.same_string (a_function_name, "current-time") then
				create {XM_XPATH_CURRENT_TIME} Result.make
			elseif STRING_.same_string (a_function_name, "empty") then
				create {XM_XPATH_EMPTY} Result.make
			elseif STRING_.same_string (a_function_name, "exists") then
				create {XM_XPATH_EXISTS} Result.make				
			elseif STRING_.same_string (a_function_name, "false") then
				create {XM_XPATH_FALSE} Result.make
			elseif STRING_.same_string (a_function_name, "id") then
				create {XM_XPATH_ID} Result.make
			elseif STRING_.same_string (a_function_name, "in-scope-prefixes") then
				create {XM_XPATH_IN_SCOPE_PREFIXES} Result.make								
			elseif STRING_.same_string (a_function_name, "last") then
				create {XM_XPATH_LAST} Result.make
			elseif STRING_.same_string (a_function_name, "local-name") then
				create {XM_XPATH_LOCAL_NAME} Result.make				
			elseif STRING_.same_string (a_function_name, "name") then
				create {XM_XPATH_NAME} Result.make
			elseif STRING_.same_string (a_function_name, "namespace-uri") then
				create {XM_XPATH_NAMESPACE_URI} Result.make				
			elseif STRING_.same_string (a_function_name, "namespace-uri-for-prefix") then
				create {XM_XPATH_NAMESPACE_URI_FOR_PREFIX} Result.make				
			elseif STRING_.same_string (a_function_name, "normalize-space") then
				create {XM_XPATH_NORMALIZE_SPACE} Result.make
			elseif STRING_.same_string (a_function_name, "not") then
				create {XM_XPATH_NOT} Result.make
			elseif STRING_.same_string (a_function_name, "number") then
				create {XM_XPATH_NUMBER} Result.make				
			elseif STRING_.same_string (a_function_name, "position") then
				create {XM_XPATH_POSITION} Result.make
			elseif STRING_.same_string (a_function_name, "starts-with") then
				create {XM_XPATH_STARTS_WITH} Result.make
			elseif STRING_.same_string (a_function_name, "string-length") then
				create {XM_XPATH_STRING_LENGTH} Result.make				
			elseif STRING_.same_string (a_function_name, "string") then
				create {XM_XPATH_STRING} Result.make
			elseif STRING_.same_string (a_function_name, "string-join") then
				create {XM_XPATH_STRING_JOIN} Result.make
			elseif STRING_.same_string (a_function_name, "substring") then
				create {XM_XPATH_SUBSTRING} Result.make
			elseif STRING_.same_string (a_function_name, "substring-before") then
				create {XM_XPATH_SUBSTRING_BEFORE} Result.make
			elseif STRING_.same_string (a_function_name, "substring-after") then
				create {XM_XPATH_SUBSTRING_AFTER} Result.make
			elseif STRING_.same_string (a_function_name, "sum") then
				create {XM_XPATH_SUM} Result.make
			elseif STRING_.same_string (a_function_name, "tokenize") then
				create {XM_XPATH_TOKENIZE} Result.make
			elseif STRING_.same_string (a_function_name, "translate") then
				create {XM_XPATH_TRANSLATE} Result.make				
			elseif STRING_.same_string (a_function_name, "true") then
				create {XM_XPATH_TRUE} Result.make				
			end
		ensure
			Void_or_correct_function: Result /= Void implies STRING_.same_string (Result.name, a_function_name)
		end

end
	
