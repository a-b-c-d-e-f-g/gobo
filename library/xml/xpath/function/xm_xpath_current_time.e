note

	description:

		"Objects that implement the XPath current-time() function"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004-2015, Colin Adams and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_CURRENT_TIME

inherit

	XM_XPATH_SYSTEM_FUNCTION
		redefine
			pre_evaluate, evaluate_item
		end

create

	make

feature {NONE} -- Initialization

	make
			-- Establish invariant
		do
			name := "current-time"; namespace_uri := Xpath_standard_functions_uri
			fingerprint := Current_time_function_type_code
			minimum_argument_count := 0
			maximum_argument_count := 0
			create arguments.make (0)
			arguments.set_equality_tester (expression_tester)
			initialized := True
		end

feature -- Access

	item_type: XM_XPATH_ITEM_TYPE
			-- Data type of the expression, where known
		do
			Result := type_factory.time_type
			if Result /= Void then
				-- Bug in SE 1.0 and 1.1: Make sure that
				-- that `Result' is not optimized away.
			end
		end

feature -- Status report

	required_type (argument_number: INTEGER): XM_XPATH_SEQUENCE_TYPE
			-- Type of argument number `argument_number'
		do
			--	do_nothing
			check False then end
		end

feature -- Evaluation

	evaluate_item (a_result: DS_CELL [detachable XM_XPATH_ITEM]; a_context: XM_XPATH_CONTEXT)
			-- Evaluate as a single item to `a_result'.
		local
			l_dt: DT_FIXED_OFFSET_ZONED_DATE_TIME
			l_zt: DT_FIXED_OFFSET_ZONED_TIME
		do
			l_dt := a_context.current_date_time
			create l_zt.make (l_dt.date_time.time, l_dt.time_zone)
			a_result.put (create {XM_XPATH_TIME_VALUE}.make_from_zoned_time (l_zt))
		ensure then
			good_result: attached a_result.item as a_result_item and then not a_result_item.is_error
		end

	pre_evaluate (a_replacement: DS_CELL [detachable XM_XPATH_EXPRESSION]; a_context: XM_XPATH_STATIC_CONTEXT)
			-- Pre-evaluate `Current' at compile time.
		do
			a_replacement.put (Current)
		end

feature {XM_XPATH_EXPRESSION} -- Restricted

	compute_cardinality
			-- Compute cardinality.
		do
			set_cardinality_exactly_one
		end

end

