indexing

	description:

		"Eiffel internal (do or once) procedures"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2002, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class ET_INTERNAL_PROCEDURE

inherit

	ET_PROCEDURE
		undefine
			reset, locals
		end

	ET_INTERNAL_ROUTINE

feature {NONE} -- Initialization

	make (a_name: like extended_name; args: like arguments; an_obsolete: like obsolete_message;
		a_preconditions: like preconditions; a_locals: like locals;
		a_compound: like compound; a_postconditions: like postconditions;
		a_rescue: like rescue_clause; a_clients: like clients;
		a_class: like implementation_class) is
			-- Create a new internal procedure.
		require
			a_name_not_void: a_name /= Void
			a_clients_not_void: a_clients /= Void
			a_class_not_void: a_class /= Void
		do
			extended_name := a_name
			hash_code := name.hash_code
			arguments := args
			is_keyword := tokens.is_keyword
			obsolete_message := an_obsolete
			preconditions := a_preconditions
			locals := a_locals
			compound := a_compound
			postconditions := a_postconditions
			rescue_clause := a_rescue
			end_keyword := tokens.end_keyword
			clients := a_clients
			implementation_class := a_class
			implementation_feature := Current
		ensure
			extended_name_set: extended_name = a_name
			arguments_set: arguments = args
			obsolete_message_set: obsolete_message = an_obsolete
			preconditions_set: preconditions = a_preconditions
			locals_set: locals = a_locals
			compound_set: compound = a_compound
			postconditions_set: postconditions = a_postconditions
			rescue_clause_set: rescue_clause = a_rescue
			clients_set: clients = a_clients
			implementation_class_set: implementation_class = a_class
			implementation_feature_set: implementation_feature = Current
		end

end
