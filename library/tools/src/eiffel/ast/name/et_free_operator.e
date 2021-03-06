note

	description:

		"Eiffel free operators"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2002-2017, Eric Bezault and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

class ET_FREE_OPERATOR

inherit

	ET_OPERATOR
		undefine
			lower_name,
			is_infix_freeop,
			is_prefix_freeop,
			is_infix, is_prefix,
			first_position,
			last_position,
			break
		end

	ET_FREE_NAME
		undefine
			first_position,
			last_position,
			break
		redefine
			is_infix_freeop,
			is_prefix_freeop,
			is_infix, is_prefix
		end

	ET_TOKEN
		rename
			make as make_token,
			text as operator_name
		end

create

	make_infix,
	make_prefix

feature {NONE} -- Initialization

	make_infix (a_free_op: like operator_name)
			-- Create a new infix free operator.
		do
			code := tokens.infix_freeop_code
			make_token (a_free_op)
			hash_code := STRING_.case_insensitive_hash_code (a_free_op)
		ensure
			is_infix_freeop: is_infix_freeop
		end

	make_prefix (a_free_op: like operator_name)
			-- Create a new prefix free operator.
		do
			code := tokens.prefix_freeop_code
			make_token (a_free_op)
			hash_code := STRING_.case_insensitive_hash_code (a_free_op)
		ensure
			is_prefix_freeop: is_prefix_freeop
		end

feature -- Status report

	is_prefix: BOOLEAN
			-- Is current feature name of the form 'prefix ...'?
		do
			Result := (code = tokens.prefix_freeop_code)
		end

	is_infix: BOOLEAN
			-- Is current feature name of the form 'infix ...'?
		do
			Result := (code = tokens.infix_freeop_code)
		end

	is_prefix_freeop: BOOLEAN
			-- Is current feature name of the form 'prefix "free-operator"'?
		do
			Result := (code = tokens.prefix_freeop_code)
		end

	is_infix_freeop: BOOLEAN
			-- Is current feature name of the form 'infix "free-operator"'?
		do
			Result := (code = tokens.infix_freeop_code)
		end

feature -- Access

	name: STRING
			-- Name of feature
		do
			if is_infix_freeop then
				create Result.make (operator_name.count + 8)
				Result.append_string (infix_double_quote)
			else
				create Result.make (operator_name.count + 9)
				Result.append_string (prefix_double_quote)
			end
			Result.append_string (operator_name)
			Result.append_character ('%"')
		end

feature -- Status setting

	set_infix
			-- Set `is_infix_freeop'.
		do
			code := tokens.infix_freeop_code
		ensure
			is_infix_freeop: is_infix_freeop
		end

	set_prefix
			-- Set `is_prefix_freeop'.
		do
			code := tokens.prefix_freeop_code
		ensure
			is_prefix_freeop: is_prefix_freeop
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR)
			-- Process current node.
		do
			a_processor.process_free_operator (Current)
		end

feature {NONE} -- Implementation

	code: CHARACTER
			-- Operator code

feature {NONE} -- Constants

	prefix_double_quote: STRING = "prefix %""
	infix_double_quote: STRING = "infix %""

end
