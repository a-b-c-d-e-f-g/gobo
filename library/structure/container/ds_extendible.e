indexing

	description:

		"Extendible containers"

	note:

		"When implementation permits, items inserted with the %
		%routines provided in this class will be internally stored %
		%in the same order as insertion so that a later traversal %
		%or retrieval will have deterministic behavior."

	library:    "Gobo Eiffel Structure Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 2001, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date$"
	revision:   "$Revision$"

deferred class DS_EXTENDIBLE [G]

inherit

	DS_SEARCHABLE [G]

feature -- Status report

	extendible (n: INTEGER): BOOLEAN is
			-- May container be extended with `n' items?
		require
			positive_n: n >= 0
		deferred
		end

feature -- Element change

	put (v: G) is
			-- Add `v' to container.
		require
			extendible: extendible (1)
		deferred
		ensure
			added: has (v)
		end

	force (v: G) is
			-- Add `v' to container.
		deferred
		ensure
			added: has (v)
		end

	extend (other: DS_LINEAR [G]) is
			-- Add items of `other' to container.
			-- Add `other.first' first, etc.
		require
			other_not_void: other /= Void
			extendible: extendible (other.count)
		deferred
		end

	append (other: DS_LINEAR [G]) is
			-- Add items of `other' to container.
			-- Add `other.first' first, etc.
		require
			other_not_void: other /= Void
		deferred
		end

end -- class DS_EXTENDIBLE
