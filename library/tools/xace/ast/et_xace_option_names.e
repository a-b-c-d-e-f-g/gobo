indexing

	description:

		"Xace option names"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2002, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_XACE_OPTION_NAMES

feature -- Option names

	address_expression_name: STRING is "address_expression"
	arguments_name: STRING is "arguments"
	array_optimization_name: STRING is "array_optimization"
	assertion_name: STRING is "assertion"
	case_insensitive_name: STRING is "case_insensitive"
	check_vape_name: STRING is "check_vape"
	clean_name: STRING is "clean"
	component_name: STRING is "component"
	console_application_name: STRING is "console_application"
	create_keyword_extension_name: STRING is "create_keyword_extension"
	dead_code_removal_name: STRING is "dead_code_removal"
	debug_option_name: STRING is "debug"
	debug_tag_name: STRING is "debug_tag"
	debugger_name: STRING is "debugger"
	document_name: STRING is "document"
	dynamic_runtime_name: STRING is "dynamic_runtime"
	exception_trace_name: STRING is "exception_trace"
	finalize_name: STRING is "finalize"
	flat_fst_optimization_name: STRING is "flat_fst_optimization"
	fst_expansion_factor_name: STRING is "fst_expansion_factor"
	fst_optimization_name: STRING is "fst_optimization"
	garbage_collector_name: STRING is "garbage_collector"
	gc_info_name: STRING is "gc_info"
	heap_size_name: STRING is "heap_size"
	inlining_name: STRING is "inlining"
	inlining_size_name: STRING is "inlining_size"
	jumps_optimization_name: STRING is "jumps_optimization"
	layout_optimization_name: STRING is "layout_optimization"
	leaves_optimization_name: STRING is "leaves_optimization"
	line_generation_name: STRING is "line_generation"
	linker_name: STRING is "linker"
	linux_fpu_double_precision_name: STRING is "linux_fpu_double_precision"
	manifest_string_trace_name: STRING is "manifest_string_trace"
	map_name: STRING is "map"
	multithreaded_name: STRING is "multithreaded"
	no_default_lib_name: STRING is "no_default_lib"
	override_cluster_name: STRING is "override_cluster"
	portable_code_generation_name: STRING is "portable_code_generation"
	precompiled_name: STRING is "precompiled"
	profile_name: STRING is "profile"
	reloads_optimization_name: STRING is "reloads_optimization"
	shared_library_definition_name: STRING is "shared_library_definition"
	split_name: STRING is "split"
	stack_size_name: STRING is "stack_size"
	storable_filename_name: STRING is "storable_filename"
	strip_option_name: STRING is "strip"
	target_name: STRING is "target"
	trace_name: STRING is "trace"
	verbose_name: STRING is "verbose"
	visible_filename_name: STRING is "visible_filename"
	warning_name: STRING is "warning"
	wedit_name: STRING is "wedit"

feature -- Option codes

	address_expression_code: INTEGER is unique
	arguments_code: INTEGER is unique
	array_optimization_code: INTEGER is unique
	assertion_code: INTEGER is unique
	case_insensitive_code: INTEGER is unique
	check_vape_code: INTEGER is unique
	clean_code: INTEGER is unique
	component_code: INTEGER is unique
	console_application_code: INTEGER is unique
	create_keyword_extension_code: INTEGER is unique
	dead_code_removal_code: INTEGER is unique
	debug_option_code: INTEGER is unique
	debug_tag_code: INTEGER is unique
	debugger_code: INTEGER is unique
	document_code: INTEGER is unique
	dynamic_runtime_code: INTEGER is unique
	exception_trace_code: INTEGER is unique
	finalize_code: INTEGER is unique
	flat_fst_optimization_code: INTEGER is unique
	fst_expansion_factor_code: INTEGER is unique
	fst_optimization_code: INTEGER is unique
	garbage_collector_code: INTEGER is unique
	gc_info_code: INTEGER is unique
	heap_size_code: INTEGER is unique
	inlining_code: INTEGER is unique
	inlining_size_code: INTEGER is unique
	jumps_optimization_code: INTEGER is unique
	layout_optimization_code: INTEGER is unique
	leaves_optimization_code: INTEGER is unique
	line_generation_code: INTEGER is unique
	linker_code: INTEGER is unique
	linux_fpu_double_precision_code: INTEGER is unique
	manifest_string_trace_code: INTEGER is unique
	map_code: INTEGER is unique
	multithreaded_code: INTEGER is unique
	no_default_lib_code: INTEGER is unique
	override_cluster_code: INTEGER is unique
	portable_code_generation_code: INTEGER is unique
	precompiled_code: INTEGER is unique
	profile_code: INTEGER is unique
	reloads_optimization_code: INTEGER is unique
	shared_library_definition_code: INTEGER is unique
	split_code: INTEGER is unique
	stack_size_code: INTEGER is unique
	storable_filename_code: INTEGER is unique
	strip_option_code: INTEGER is unique
	target_code: INTEGER is unique
	trace_code: INTEGER is unique
	verbose_code: INTEGER is unique
	visible_filename_code: INTEGER is unique
	warning_code: INTEGER is unique
	wedit_code: INTEGER is unique

	option_codes: DS_HASH_TABLE [INTEGER, STRING] is
			-- Mapping option names -> option codes
		once
			!! Result.make_equal (52)
			Result.put_new (address_expression_code, address_expression_name)
			Result.put_new (arguments_code, arguments_name)
			Result.put_new (array_optimization_code, array_optimization_name)
			Result.put_new (assertion_code, assertion_name)
			Result.put_new (case_insensitive_code, case_insensitive_name)
			Result.put_new (check_vape_code, check_vape_name)
			Result.put_new (clean_code, clean_name)
			Result.put_new (component_code, component_name)
			Result.put_new (console_application_code, console_application_name)
			Result.put_new (create_keyword_extension_code, create_keyword_extension_name)
			Result.put_new (dead_code_removal_code, dead_code_removal_name)
			Result.put_new (debug_option_code, debug_option_name)
			Result.put_new (debug_tag_code, debug_tag_name)
			Result.put_new (debugger_code, debugger_name)
			Result.put_new (document_code, document_name)
			Result.put_new (dynamic_runtime_code, dynamic_runtime_name)
			Result.put_new (exception_trace_code, exception_trace_name)
			Result.put_new (finalize_code, finalize_name)
			Result.put_new (flat_fst_optimization_code, flat_fst_optimization_name)
			Result.put_new (fst_expansion_factor_code, fst_expansion_factor_name)
			Result.put_new (fst_optimization_code, fst_optimization_name)
			Result.put_new (garbage_collector_code, garbage_collector_name)
			Result.put_new (gc_info_code, gc_info_name)
			Result.put_new (heap_size_code, heap_size_name)
			Result.put_new (inlining_code, inlining_name)
			Result.put_new (inlining_size_code, inlining_size_name)
			Result.put_new (jumps_optimization_code, jumps_optimization_name)
			Result.put_new (layout_optimization_code, layout_optimization_name)
			Result.put_new (leaves_optimization_code, leaves_optimization_name)
			Result.put_new (line_generation_code, line_generation_name)
			Result.put_new (linker_code, linker_name)
			Result.put_new (linux_fpu_double_precision_code, linux_fpu_double_precision_name)
			Result.put_new (manifest_string_trace_code, manifest_string_trace_name)
			Result.put_new (map_code, map_name)
			Result.put_new (multithreaded_code, multithreaded_name)
			Result.put_new (no_default_lib_code, no_default_lib_name)
			Result.put_new (override_cluster_code, override_cluster_name)
			Result.put_new (portable_code_generation_code, portable_code_generation_name)
			Result.put_new (precompiled_code, precompiled_name)
			Result.put_new (profile_code, profile_name)
			Result.put_new (reloads_optimization_code, reloads_optimization_name)
			Result.put_new (shared_library_definition_code, shared_library_definition_name)
			Result.put_new (split_code, split_name)
			Result.put_new (stack_size_code, stack_size_name)
			Result.put_new (storable_filename_code, storable_filename_name)
			Result.put_new (strip_option_code, strip_option_name)
			Result.put_new (target_code, target_name)
			Result.put_new (trace_code, trace_name)
			Result.put_new (verbose_code, verbose_name)
			Result.put_new (visible_filename_code, visible_filename_name)
			Result.put_new (warning_code, warning_name)
			Result.put_new (wedit_code, wedit_name)
		ensure
			options_code_not_void: Result /= Void
			no_void_option_name: not Result.has (Void)
		end

feature -- Option values

	all_value: STRING is "all"
	array_value: STRING is "array"
	boehm_value: STRING is "boehm"
	check_value: STRING is "check"
	class_value: STRING is "class"
	com_value: STRING is "com"
	constant_value: STRING is "constant"
	default_value: STRING is "default"
	dll_value: STRING is "dll"
	ensure_value: STRING is "ensure"
	exe_value: STRING is "exe"
	feature_value: STRING is "feature"
	internal_value: STRING is "internal"
	invariant_value: STRING is "invariant"
	loop_invariant_value: STRING is "loop_invariant"
	loop_variant_value: STRING is "loop_variant"
	low_level_value: STRING is "low_level"
	microsoft_value: STRING is "microsoft"
	no_main_value: STRING is "no_main"
	none_value: STRING is "none"
	once_value: STRING is "once"
	require_value: STRING is "require"
	style_value: STRING is "style"

end
