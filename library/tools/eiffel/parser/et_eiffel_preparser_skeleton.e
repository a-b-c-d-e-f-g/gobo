indexing

	description:

		"Eiffel preparser skeletons"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2002-2004, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class ET_EIFFEL_PREPARSER_SKELETON

inherit

	ET_EIFFEL_SCANNER_SKELETON
		rename
			make as make_eiffel_scanner,
			make_with_factory as make_eiffel_scanner_with_factory
		redefine
			reset
		end

	ET_SHARED_EIFFEL_BUFFER
		export {NONE} all end

	KL_SHARED_EXECUTION_ENVIRONMENT
	KL_SHARED_FILE_SYSTEM

feature {NONE} -- Initialization

	make (a_universe: ET_UNIVERSE; an_error_handler: like error_handler) is
			-- Create a new Eiffel preparser.
		require
			a_universe_not_void: a_universe /= Void
			an_error_handler_not_void: an_error_handler /= Void
		local
			a_factory: ET_AST_FACTORY
		do
			create a_factory.make
			make_with_factory (a_universe, a_factory, an_error_handler)
		ensure
			universe_set: universe = a_universe
			error_handler_set: error_handler = an_error_handler
		end

	make_with_factory (a_universe: ET_UNIVERSE; a_factory: like ast_factory;
		an_error_handler: like error_handler) is
			-- Create a new Eiffel preparser.
		require
			a_universe_not_void: a_universe /= Void
			a_factory_not_void: a_factory /= Void
			an_error_handler_not_void: an_error_handler /= Void
		do
			universe := a_universe
			make_eiffel_scanner_with_factory ("unknown file", a_factory, an_error_handler)
		ensure
			universe_set: universe = a_universe
			ast_factory_set: ast_factory = a_factory
			error_handler_set: error_handler = an_error_handler
		end

feature -- Initialization

	reset is
			-- Reset parser before parsing next input.
		do
			precursor
			Eiffel_buffer.set_end_of_file
			class_keyword_found := False
			last_classname := Void
		end

feature -- Status report

	class_keyword_found: BOOLEAN
			-- Has a 'class' keyword been found?

feature -- Access

	universe: ET_UNIVERSE
			-- Surrounding universe

	last_classname: ET_CLASS_NAME
			-- Last classname found

feature -- Parsing

	preparse_cluster_shallow (a_cluster: ET_CLUSTER) is
			-- Traverse `a_cluster' (recursively) and build a mapping
			-- between class names and filenames. Classes are added to
			-- `universe.classes', but are not parsed. Filenames are
			-- supposed to be of the form 'classname.e'.
		require
			a_cluster_not_void: a_cluster /= Void
		local
			a_filename: STRING
			dir_name: STRING
			dir: KL_DIRECTORY
			s: STRING
			a_classname: ET_IDENTIFIER
			a_class: ET_CLASS
			l_other_class: ET_CLASS
			l_subclusters: ET_CLUSTERS
		do
			if not a_cluster.is_abstract then
				error_handler.report_preparsing_status (a_cluster)
				dir_name := Execution_environment.interpreted_string (a_cluster.full_pathname)
				dir := tmp_directory
				dir.reset (dir_name)
				dir.open_read
				if dir.is_open_read then
					from dir.read_entry until dir.end_of_input loop
						s := dir.last_entry
						if a_cluster.is_valid_eiffel_filename (s) then
							a_filename := file_system.pathname (dir_name, s)
							create a_classname.make (s.substring (1, s.count - 2))
							a_class := universe.eiffel_class (a_classname)
							if a_class.is_preparsed then
								if a_cluster.is_override then
									if a_class.is_override then
											-- Two classes with the same name in two override clusters.
										l_other_class := a_class.cloned_class
										l_other_class.reset_all
										l_other_class.set_filename (a_filename)
										l_other_class.set_cluster (a_cluster)
										l_other_class.set_overridden_class (a_class.overridden_class)
										a_class.set_overridden_class (l_other_class)
										error_handler.report_vscn0a_error (a_class, a_cluster, a_filename)
									else
											-- Override.
										l_other_class := a_class.cloned_class
										l_other_class.set_overridden_class (a_class.overridden_class)
										a_class.reset_all
										a_class.set_filename (a_filename)
										a_class.set_cluster (a_cluster)
										a_class.set_overridden_class (l_other_class)
									end
								elseif not a_class.is_override then
										-- Two classes with the same name in two non-override clusters.
									l_other_class := a_class.cloned_class
									l_other_class.reset_all
									l_other_class.set_filename (a_filename)
									l_other_class.set_cluster (a_cluster)
									l_other_class.set_overridden_class (a_class.overridden_class)
									a_class.set_overridden_class (l_other_class)
									error_handler.report_vscn0a_error (a_class, a_cluster, a_filename)
								else
									l_other_class := a_class.cloned_class
									l_other_class.reset_all
									l_other_class.set_filename (a_filename)
									l_other_class.set_cluster (a_cluster)
									l_other_class.set_overridden_class (a_class.overridden_class)
									a_class.set_overridden_class (l_other_class)
								end
							else
								a_class.set_filename (a_filename)
								a_class.set_cluster (a_cluster)
							end
						elseif a_cluster.is_recursive and then a_cluster.is_valid_directory_name (s) then
							if file_system.directory_exists (file_system.pathname (dir_name, s)) then
								a_cluster.add_recursive_cluster (s)
							end
						end
						dir.read_entry
					end
					dir.close
				else
					error_handler.report_gcaaa_error (a_cluster, dir_name)
				end
			end
			l_subclusters := a_cluster.subclusters
			if l_subclusters /= Void then
				preparse_clusters_shallow (l_subclusters)
			end
		end

	preparse_clusters_shallow (a_clusters: ET_CLUSTERS) is
			-- Traverse `a_clusters' (recursively) and build a mapping
			-- between class names and filenames in each cluster. Classes
			-- are added to `universe.classes', but are not parsed.
			-- Filenames are supposed to be of the form 'classname.e'.
		require
			a_clusters_not_void: a_clusters /= Void
		local
			l_clusters: DS_ARRAYED_LIST [ET_CLUSTER]
			i, nb: INTEGER
		do
			l_clusters := a_clusters.clusters
			nb := l_clusters.count
			from i := 1 until i > nb loop
				preparse_cluster_shallow (l_clusters.item (i))
				i := i + 1
			end
		end

	repreparse_cluster_shallow (a_cluster: ET_CLUSTER; a_override: BOOLEAN) is
			-- Traverse `a_cluster' (recursively) again and rebuild a mapping
			-- between class names and filenames. Classes are added to
			-- `universe.classes', but are not parsed. Filenames are
			-- supposed to be of the form 'classname.e'.
			-- `a_override' means that only override clusters are taken into account.
		require
			a_cluster_not_void: a_cluster /= Void
		local
			a_filename: STRING
			dir_name: STRING
			dir: KL_DIRECTORY
			s: STRING
			a_classname: ET_IDENTIFIER
			a_class: ET_CLASS
			l_other_class: ET_CLASS
			l_subclusters: ET_CLUSTERS
			l_classes: DS_ARRAYED_LIST [ET_CLASS]
			i, nb: INTEGER
		do
			if (a_override implies a_cluster.is_override) and then not a_cluster.is_abstract then
				error_handler.report_preparsing_status (a_cluster)
				dir_name := Execution_environment.interpreted_string (a_cluster.full_pathname)
				dir := tmp_directory
				dir.reset (dir_name)
				dir.open_read
				if dir.is_open_read then
					from dir.read_entry until dir.end_of_input loop
						s := dir.last_entry
						if a_cluster.is_valid_eiffel_filename (s) then
							a_filename := file_system.pathname (dir_name, s)
							if l_classes = Void then
								l_classes := universe.classes_by_cluster (a_cluster)
							end
							a_class := Void
							nb := l_classes.count
							from i := 1 until i > nb loop
								a_class := l_classes.item (i)
								if STRING_.same_string (a_class.filename, a_filename) then
									i := nb + 1
								else
									a_class := Void
									i := i + 1
								end
							end
							if a_class = Void then
									-- This file is either new or has been marked as modified.
									-- We need to analyze it again.
								create a_classname.make (s.substring (1, s.count - 2))
								a_class := universe.eiffel_class (a_classname)
								if a_class.is_preparsed then
									if a_cluster.is_override then
										if a_class.is_override then
												-- Two classes with the same name in two override clusters.
											l_other_class := a_class.cloned_class
											l_other_class.reset_all
											l_other_class.set_filename (a_filename)
											l_other_class.set_cluster (a_cluster)
											l_other_class.set_overridden_class (a_class.overridden_class)
											a_class.set_overridden_class (l_other_class)
											error_handler.report_vscn0a_error (a_class, a_cluster, a_filename)
										else
												-- Override.
											l_other_class := a_class.cloned_class
											l_other_class.set_overridden_class (a_class.overridden_class)
											a_class.reset_all
											a_class.set_filename (a_filename)
											a_class.set_cluster (a_cluster)
											a_class.set_overridden_class (l_other_class)
										end
									elseif not a_class.is_override then
											-- Two classes with the same name in two non-override clusters.
										l_other_class := a_class.cloned_class
										l_other_class.reset_all
										l_other_class.set_filename (a_filename)
										l_other_class.set_cluster (a_cluster)
										l_other_class.set_overridden_class (a_class.overridden_class)
										a_class.set_overridden_class (l_other_class)
										error_handler.report_vscn0a_error (a_class, a_cluster, a_filename)
									else
										l_other_class := a_class.cloned_class
										l_other_class.reset_all
										l_other_class.set_filename (a_filename)
										l_other_class.set_cluster (a_cluster)
										l_other_class.set_overridden_class (a_class.overridden_class)
										a_class.set_overridden_class (l_other_class)
									end
								else
									a_class.set_filename (a_filename)
									a_class.set_cluster (a_cluster)
								end
							end
						elseif a_cluster.is_recursive and then a_cluster.is_valid_directory_name (s) then
							if file_system.directory_exists (file_system.pathname (dir_name, s)) then
								a_cluster.add_recursive_cluster (s)
							end
						end
						dir.read_entry
					end
					dir.close
				else
					error_handler.report_gcaaa_error (a_cluster, dir_name)
				end
			end
			l_subclusters := a_cluster.subclusters
			if l_subclusters /= Void then
				repreparse_clusters_shallow (l_subclusters, a_override)
			end
		end

	repreparse_clusters_shallow (a_clusters: ET_CLUSTERS; a_override: BOOLEAN) is
			-- Traverse `a_clusters' (recursively) again and rebuild a mapping
			-- between class names and filenames in each cluster. Classes
			-- are added to `universe.classes', but are not parsed.
			-- Filenames are supposed to be of the form 'classname.e'.
			-- `a_override' means that only override clusters are taken into account.
		require
			a_clusters_not_void: a_clusters /= Void
		local
			l_clusters: DS_ARRAYED_LIST [ET_CLUSTER]
			l_cluster: ET_CLUSTER
			dir_name: STRING
			i, nb: INTEGER
		do
			l_clusters := a_clusters.clusters
			nb := l_clusters.count
			from i := 1 until i > nb loop
				l_cluster := l_clusters.item (i)
				if l_cluster.is_implicit and then (a_override implies l_cluster.is_override) then
					dir_name := Execution_environment.interpreted_string (l_cluster.full_pathname)
					if not file_system.directory_exists (dir_name) then
						l_clusters.remove (i)
						nb := nb - 1
					else
						repreparse_cluster_shallow (l_cluster, a_override)
						i := i + 1
					end
				else
					repreparse_cluster_shallow (l_cluster, a_override)
					i := i + 1
				end
			end
		end

	preparse_file_single (a_file: KI_CHARACTER_INPUT_STREAM; a_filename: STRING; a_time_stamp: INTEGER; a_cluster: ET_CLUSTER) is
			-- Scan Eiffel file `a_file' to find the name of the class it
			-- contains. The file is supposed to contain exactly one class.
			-- Add the class to `universe.classes', but do not parse it.
			-- `a_filename' is the filename of `a_file' and `a_time_stamp'
			-- its time stamp just before it was open.
		require
			a_file_not_void: a_file /= Void
			a_file_open_read: a_file.is_open_read
			a_filename_not_void: a_filename /= Void
			a_cluster_not_void: a_cluster /= Void
		local
			a_class: ET_CLASS
			l_other_class: ET_CLASS
		do
			filename := a_filename
			input_buffer := Eiffel_buffer
			Eiffel_buffer.set_file (a_file)
			yy_load_input_buffer
			read_token
			if last_classname /= Void then
				a_class := universe.eiffel_class (last_classname)
				if a_class.is_preparsed then
					if a_cluster.is_override then
						if a_class.is_override then
								-- Two classes with the same name in two override clusters.
							l_other_class := a_class.cloned_class
							l_other_class.reset_all
							l_other_class.set_filename (a_filename)
							l_other_class.set_time_stamp (a_time_stamp)
							l_other_class.set_cluster (a_cluster)
							l_other_class.set_overridden_class (a_class.overridden_class)
							a_class.set_overridden_class (l_other_class)
							error_handler.report_vscn0a_error (a_class, a_cluster, filename)
						else
								-- Override.
							l_other_class := a_class.cloned_class
							l_other_class.set_overridden_class (a_class.overridden_class)
							a_class.reset_all
							a_class.set_filename (a_filename)
							a_class.set_time_stamp (a_time_stamp)
							a_class.set_cluster (a_cluster)
							a_class.set_overridden_class (l_other_class)
						end
					elseif not a_class.is_override then
							-- Two classes with the same name in two non-override clusters.
						l_other_class := a_class.cloned_class
						l_other_class.reset_all
						l_other_class.set_filename (a_filename)
						l_other_class.set_time_stamp (a_time_stamp)
						l_other_class.set_cluster (a_cluster)
						l_other_class.set_overridden_class (a_class.overridden_class)
						a_class.set_overridden_class (l_other_class)
						error_handler.report_vscn0a_error (a_class, a_cluster, filename)
					else
						l_other_class := a_class.cloned_class
						l_other_class.reset_all
						l_other_class.set_filename (a_filename)
						l_other_class.set_time_stamp (a_time_stamp)
						l_other_class.set_cluster (a_cluster)
						l_other_class.set_overridden_class (a_class.overridden_class)
						a_class.set_overridden_class (l_other_class)
					end
				else
					a_class.set_filename (a_filename)
					a_class.set_time_stamp (a_time_stamp)
					a_class.set_cluster (a_cluster)
				end
			else
					-- No class name found.
				error_handler.report_syntax_error (filename, current_position)
			end
			reset
		rescue
			reset
		end

	preparse_cluster_single (a_cluster: ET_CLUSTER) is
			-- Traverse `a_cluster' (recursively) and build a mapping
			-- between class names and filenames. Classes are added to 
			-- `universe.classes', but are not parsed. Each Eiffel file
			-- is supposed to contain exactly one class.
		require
			a_cluster_not_void: a_cluster /= Void
		local
			a_filename: STRING
			a_file: KL_TEXT_INPUT_FILE
			a_time_stamp: INTEGER
			dir_name: STRING
			dir: KL_DIRECTORY
			s: STRING
			l_subclusters: ET_CLUSTERS
		do
			if not a_cluster.is_abstract then
				error_handler.report_preparsing_status (a_cluster)
				dir_name := Execution_environment.interpreted_string (a_cluster.full_pathname)
				dir := tmp_directory
				dir.reset (dir_name)
				dir.open_read
				if dir.is_open_read then
					from dir.read_entry until dir.end_of_input loop
						s := dir.last_entry
						if a_cluster.is_valid_eiffel_filename (s) then
							a_filename := file_system.pathname (dir_name, s)
							a_file := tmp_file
							a_file.reset (a_filename)
							if eiffel_compiler.is_se then
									-- KL_FILE.time_stamp is too slow with SE.
								a_time_stamp := -1
							else
								a_time_stamp := a_file.time_stamp
							end
							a_file.open_read
							if a_file.is_open_read then
								preparse_file_single (a_file, a_filename, a_time_stamp, a_cluster)
								a_file.close
							else
								error_handler.report_gcaab_error (a_cluster, a_filename)
							end
						elseif a_cluster.is_recursive and then a_cluster.is_valid_directory_name (s) then
							if file_system.directory_exists (file_system.pathname (dir_name, s)) then
								a_cluster.add_recursive_cluster (s)
							end
						end
						dir.read_entry
					end
					dir.close
				else
					error_handler.report_gcaaa_error (a_cluster, dir_name)
				end
			end
			l_subclusters := a_cluster.subclusters
			if l_subclusters /= Void then
				preparse_clusters_single (l_subclusters)
			end
		end

	preparse_clusters_single (a_clusters: ET_CLUSTERS) is
			-- Traverse `a_clusters' (recursively) and build a mapping between
			-- class names and filenames in each cluster. Classes are added to
			-- `universe.classes', but are not parsed. Each Eiffel file is
			-- supposed to contain exactly one class.
		require
			a_clusters_not_void: a_clusters /= Void
		local
			l_clusters: DS_ARRAYED_LIST [ET_CLUSTER]
			i, nb: INTEGER
		do
			l_clusters := a_clusters.clusters
			nb := l_clusters.count
			from i := 1 until i > nb loop
				preparse_cluster_single (l_clusters.item (i))
				i := i + 1
			end
		end

	repreparse_cluster_single (a_cluster: ET_CLUSTER; a_override: BOOLEAN) is
			-- Traverse `a_cluster' (recursively) again and rebuild a mapping between
			-- class names and filenames. Classes are added to `universe.classes', but
			-- are not parsed. Each Eiffel file is supposed to contain exactly one class.
			-- `a_override' means that only override clusters are taken into account.
		require
			a_cluster_not_void: a_cluster /= Void
		local
			a_filename: STRING
			a_file: KL_TEXT_INPUT_FILE
			a_time_stamp: INTEGER
			dir_name: STRING
			dir: KL_DIRECTORY
			s: STRING
			l_subclusters: ET_CLUSTERS
			l_classes: DS_ARRAYED_LIST [ET_CLASS]
			l_class: ET_CLASS
			i, nb: INTEGER
		do
			if (a_override implies a_cluster.is_override) and then not a_cluster.is_abstract then
				error_handler.report_preparsing_status (a_cluster)
				dir_name := Execution_environment.interpreted_string (a_cluster.full_pathname)
				dir := tmp_directory
				dir.reset (dir_name)
				dir.open_read
				if dir.is_open_read then
					from dir.read_entry until dir.end_of_input loop
						s := dir.last_entry
						if a_cluster.is_valid_eiffel_filename (s) then
							a_filename := file_system.pathname (dir_name, s)
							if l_classes = Void then
								l_classes := universe.classes_by_cluster (a_cluster)
							end
							l_class := Void
							nb := l_classes.count
							from i := 1 until i > nb loop
								l_class := l_classes.item (i)
								if STRING_.same_string (l_class.filename, a_filename) then
									i := nb + 1
								else
									l_class := Void
									i := i + 1
								end
							end
							if l_class = Void then
									-- This file is either new or has been marked as modified.
									-- We need to analyze it again.
								a_file := tmp_file
								a_file.reset (a_filename)
								if eiffel_compiler.is_se then
										-- KL_FILE.time_stamp is too slow with SE.
									a_time_stamp := -1
								else
									a_time_stamp := a_file.time_stamp
								end
								a_file.open_read
								if a_file.is_open_read then
									preparse_file_single (a_file, a_filename, a_time_stamp, a_cluster)
									a_file.close
								else
									error_handler.report_gcaab_error (a_cluster, a_filename)
								end
							end
						elseif a_cluster.is_recursive and then a_cluster.is_valid_directory_name (s) then
							if file_system.directory_exists (file_system.pathname (dir_name, s)) then
								a_cluster.add_recursive_cluster (s)
							end
						end
						dir.read_entry
					end
					dir.close
				else
					error_handler.report_gcaaa_error (a_cluster, dir_name)
				end
			end
			l_subclusters := a_cluster.subclusters
			if l_subclusters /= Void then
				repreparse_clusters_single (l_subclusters, a_override)
			end
		end

	repreparse_clusters_single (a_clusters: ET_CLUSTERS; a_override: BOOLEAN) is
			-- Traverse `a_clusters' (recursively) again and rebuild a mapping between
			-- class names and filenames in each cluster. Classes are added to
			-- `universe.classes', but are not parsed. Each Eiffel file is supposed
			-- to contain exactly one class.
			-- `a_override' means that only override clusters are taken into account.
		require
			a_clusters_not_void: a_clusters /= Void
		local
			l_clusters: DS_ARRAYED_LIST [ET_CLUSTER]
			l_cluster: ET_CLUSTER
			dir_name: STRING
			i, nb: INTEGER
		do
			l_clusters := a_clusters.clusters
			nb := l_clusters.count
			from i := 1 until i > nb loop
				l_cluster := l_clusters.item (i)
				if l_cluster.is_implicit and then (a_override implies l_cluster.is_override) then
					dir_name := Execution_environment.interpreted_string (l_cluster.full_pathname)
					if not file_system.directory_exists (dir_name) then
						l_clusters.remove (i)
						nb := nb - 1
					else
						repreparse_cluster_single (l_cluster, a_override)
						i := i + 1
					end
				else
					repreparse_cluster_single (l_cluster, a_override)
					i := i + 1
				end
			end
		end

	preparse_file_multiple (a_file: KI_CHARACTER_INPUT_STREAM; a_filename: STRING; a_time_stamp: INTEGER; a_cluster: ET_CLUSTER) is
			-- Scan Eiffel file `a_file' to find the names of the classes
			-- it contains. The file can contain more than one class. Add
			-- the classes to `universe.classes', but do not parse them.
			-- `a_filename' is the filename of `a_file' and `a_time_stamp'
			-- its time stamp just before it was open.
		require
			a_file_not_void: a_file /= Void
			a_file_open_read: a_file.is_open_read
			a_filename_not_void: a_filename /= Void
			a_cluster_not_void: a_cluster /= Void
		local
			a_class: ET_CLASS
			l_other_class: ET_CLASS
		do
			filename := a_filename
			input_buffer := Eiffel_buffer
			Eiffel_buffer.set_file (a_file)
			yy_load_input_buffer
			from
				read_token
				if last_classname = Void then
						-- No class name found.
					error_handler.report_syntax_error (filename, current_position)
				end
			until
				last_classname = Void
			loop
				a_class := universe.eiffel_class (last_classname)
				if a_class.is_preparsed then
					if a_cluster.is_override then
						if a_class.is_override then
								-- Two classes with the same name in two override clusters.
							l_other_class := a_class.cloned_class
							l_other_class.reset_all
							l_other_class.set_filename (a_filename)
							l_other_class.set_time_stamp (a_time_stamp)
							l_other_class.set_cluster (a_cluster)
							l_other_class.set_overridden_class (a_class.overridden_class)
							a_class.set_overridden_class (l_other_class)
							error_handler.report_vscn0a_error (a_class, a_cluster, filename)
						else
								-- Override.
							l_other_class := a_class.cloned_class
							l_other_class.set_overridden_class (a_class.overridden_class)
							a_class.reset_all
							a_class.set_filename (a_filename)
							a_class.set_time_stamp (a_time_stamp)
							a_class.set_cluster (a_cluster)
							a_class.set_overridden_class (l_other_class)
						end
					elseif not a_class.is_override then
							-- Two classes with the same name in two non-override clusters.
						l_other_class := a_class.cloned_class
						l_other_class.reset_all
						l_other_class.set_filename (a_filename)
						l_other_class.set_time_stamp (a_time_stamp)
						l_other_class.set_cluster (a_cluster)
						l_other_class.set_overridden_class (a_class.overridden_class)
						a_class.set_overridden_class (l_other_class)
						error_handler.report_vscn0a_error (a_class, a_cluster, filename)
					else
						l_other_class := a_class.cloned_class
						l_other_class.reset_all
						l_other_class.set_filename (a_filename)
						l_other_class.set_time_stamp (a_time_stamp)
						l_other_class.set_cluster (a_cluster)
						l_other_class.set_overridden_class (a_class.overridden_class)
						a_class.set_overridden_class (l_other_class)
					end
				else
					a_class.set_filename (a_filename)
					a_class.set_time_stamp (a_time_stamp)
					a_class.set_cluster (a_cluster)
				end
				class_keyword_found := False
				last_classname := Void
				read_token
			end
			reset
		rescue
			reset
		end

	preparse_cluster_multiple (a_cluster: ET_CLUSTER) is
			-- Traverse `a_cluster' (recursively) and build a mapping between
			-- class names and filenames. Classes are added to `universe.classes',
			-- but are not parsed. Each Eiffel file can contain more than one class.
		require
			a_cluster_not_void: a_cluster /= Void
		local
			a_filename: STRING
			a_file: KL_TEXT_INPUT_FILE
			a_time_stamp: INTEGER
			dir_name: STRING
			dir: KL_DIRECTORY
			s: STRING
			l_subclusters: ET_CLUSTERS
		do
			if not a_cluster.is_abstract then
				error_handler.report_preparsing_status (a_cluster)
				dir_name := Execution_environment.interpreted_string (a_cluster.full_pathname)
				dir := tmp_directory
				dir.reset (dir_name)
				dir.open_read
				if dir.is_open_read then
					from dir.read_entry until dir.end_of_input loop
						s := dir.last_entry
						if a_cluster.is_valid_eiffel_filename (s) then
							a_filename := file_system.pathname (dir_name, s)
							a_file := tmp_file
							a_file.reset (a_filename)
							if eiffel_compiler.is_se then
									-- KL_FILE.time_stamp is too slow with SE.
								a_time_stamp := -1
							else
								a_time_stamp := a_file.time_stamp
							end
							a_file.open_read
							if a_file.is_open_read then
								preparse_file_multiple (a_file, a_filename, a_time_stamp, a_cluster)
								a_file.close
							else
								error_handler.report_gcaab_error (a_cluster, a_filename)
							end
						elseif a_cluster.is_recursive and then a_cluster.is_valid_directory_name (s) then
							if file_system.directory_exists (file_system.pathname (dir_name, s)) then
								a_cluster.add_recursive_cluster (s)
							end
						end
						dir.read_entry
					end
					dir.close
				else
					error_handler.report_gcaaa_error (a_cluster, dir_name)
				end
			end
			l_subclusters := a_cluster.subclusters
			if l_subclusters /= Void then
				preparse_clusters_multiple (l_subclusters)
			end
		end

	preparse_clusters_multiple (a_clusters: ET_CLUSTERS) is
			-- Traverse `a_clusters' (recursively) and build a mapping between
			-- class names and filenames in each cluster. Classes are added to
			-- `universe.classes', but are not parsed. Each Eiffel file can
			-- contain more than one class.
		require
			a_clusters_not_void: a_clusters /= Void
		local
			l_clusters: DS_ARRAYED_LIST [ET_CLUSTER]
			i, nb: INTEGER
		do
			l_clusters := a_clusters.clusters
			nb := l_clusters.count
			from i := 1 until i > nb loop
				preparse_cluster_multiple (l_clusters.item (i))
				i := i + 1
			end
		end

	repreparse_cluster_multiple (a_cluster: ET_CLUSTER; a_override: BOOLEAN) is
			-- Traverse `a_cluster' (recursively) again and rebuild a mapping between
			-- class names and filenames. Classes are added to `universe.classes', but
			-- are not parsed. Each Eiffel file can contain more than one class.
			-- `a_override' means that only override clusters are taken into account.
		require
			a_cluster_not_void: a_cluster /= Void
		local
			a_filename: STRING
			a_file: KL_TEXT_INPUT_FILE
			a_time_stamp: INTEGER
			dir_name: STRING
			dir: KL_DIRECTORY
			s: STRING
			l_subclusters: ET_CLUSTERS
			l_classes: DS_ARRAYED_LIST [ET_CLASS]
			l_class: ET_CLASS
			i, nb: INTEGER
		do
			if (a_override implies a_cluster.is_override) and then not a_cluster.is_abstract then
				error_handler.report_preparsing_status (a_cluster)
				dir_name := Execution_environment.interpreted_string (a_cluster.full_pathname)
				dir := tmp_directory
				dir.reset (dir_name)
				dir.open_read
				if dir.is_open_read then
					from dir.read_entry until dir.end_of_input loop
						s := dir.last_entry
						if a_cluster.is_valid_eiffel_filename (s) then
							a_filename := file_system.pathname (dir_name, s)
							if l_classes = Void then
								l_classes := universe.classes_by_cluster (a_cluster)
							end
							l_class := Void
							nb := l_classes.count
							from i := 1 until i > nb loop
								l_class := l_classes.item (i)
								if STRING_.same_string (l_class.filename, a_filename) then
									i := nb + 1
								else
									l_class := Void
									i := i + 1
								end
							end
							if l_class = Void then
									-- This file is either new or has been marked as modified.
									-- We need to analyze it again.
								a_file := tmp_file
								a_file.reset (a_filename)
								if eiffel_compiler.is_se then
										-- KL_FILE.time_stamp is too slow with SE.
									a_time_stamp := -1
								else
									a_time_stamp := a_file.time_stamp
								end
								a_file.open_read
								if a_file.is_open_read then
									preparse_file_multiple (a_file, a_filename, a_time_stamp, a_cluster)
									a_file.close
								else
									error_handler.report_gcaab_error (a_cluster, a_filename)
								end
							end
						elseif a_cluster.is_recursive and then a_cluster.is_valid_directory_name (s) then
							if file_system.directory_exists (file_system.pathname (dir_name, s)) then
								a_cluster.add_recursive_cluster (s)
							end
						end
						dir.read_entry
					end
					dir.close
				else
					error_handler.report_gcaaa_error (a_cluster, dir_name)
				end
			end
			l_subclusters := a_cluster.subclusters
			if l_subclusters /= Void then
				repreparse_clusters_multiple (l_subclusters, a_override)
			end
		end

	repreparse_clusters_multiple (a_clusters: ET_CLUSTERS; a_override: BOOLEAN) is
			-- Traverse `a_clusters' (recursively) again and rebuild a mapping between
			-- class names and filenames in each cluster. Classes are added to
			-- `universe.classes', but are not parsed. Each Eiffel file can
			-- contain more than one class.
			-- `a_override' means that only override clusters are taken into account.
		require
			a_clusters_not_void: a_clusters /= Void
		local
			l_clusters: DS_ARRAYED_LIST [ET_CLUSTER]
			l_cluster: ET_CLUSTER
			dir_name: STRING
			i, nb: INTEGER
		do
			l_clusters := a_clusters.clusters
			nb := l_clusters.count
			from i := 1 until i > nb loop
				l_cluster := l_clusters.item (i)
				if l_cluster.is_implicit and then (a_override implies l_cluster.is_override) then
					dir_name := Execution_environment.interpreted_string (l_cluster.full_pathname)
					if not file_system.directory_exists (dir_name) then
						l_clusters.remove (i)
						nb := nb - 1
					else
						repreparse_cluster_multiple (l_cluster, a_override)
						i := i + 1
					end
				else
					repreparse_cluster_multiple (l_cluster, a_override)
					i := i + 1
				end
			end
		end

feature -- Error handling

	report_error (a_message: STRING) is
			-- Print error message.
		do
			error_handler.report_syntax_error (filename, current_position)
		end

feature {NONE} -- Implementation

	tmp_directory: KL_DIRECTORY is
			-- Temporary directory object
		do
			Result := shared_directory
			if not Result.is_closed then
				create Result.make (dummy_name)
			end
		ensure
			directory_not_void: Result /= Void
			directory_closed: Result.is_closed
		end

	shared_directory: KL_DIRECTORY is
			-- Shared directory object
		once
			create Result.make (dummy_name)
		ensure
			directory_not_void: Result /= Void
		end

invariant

	universe_not_void: universe /= Void

end
