/*
	description:

		"C functions used to implement class THREAD and related threading facilities"

	system: "Gobo Eiffel Compiler"
	copyright: "Copyright (c) 2016-2017, Eric Bezault and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"
*/

#ifndef GE_THREAD_C
#define GE_THREAD_C
#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#ifdef GE_USE_THREADS

#ifndef GE_THREAD_H
#include "ge_thread.h"
#endif
#ifndef GE_GC_H
#include "ge_gc.h"
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef EIF_POSIX_THREADS
#	define EIF_TSD_VAL_TYPE        void*
#	define EIF_TSD_TYPE            pthread_key_t
#	define EIF_TSD_CREATE(key,msg) \
		if (pthread_key_create(&(key),NULL)) \
	        GE_raise_with_message(GE_EX_EXT, msg)
#	define EIF_TSD_SET(key,val,msg) \
		if (pthread_setspecific((key), (EIF_TSD_VAL_TYPE)(val))) \
			GE_raise_with_message(GE_EX_EXT, msg)
#	define EIF_TSD_GET0(val_type,key,val) (val = pthread_getspecific(key))
#	define EIF_TSD_GET(val_type,key,val,msg) \
		if (EIF_TSD_GET0(val_type,key,val) == (void*) 0) GE_raise_with_message(GE_EX_EXT, msg)
#	define EIF_TSD_DESTROY(key,msg) if (pthread_key_delete(key)) GE_raise_with_message(GE_EX_EXT, msg)
#elif defined EIF_WINDOWS
#	define EIF_TSD_VAL_TYPE        LPVOID
#	define EIF_TSD_TYPE            DWORD
#	define EIF_TSD_CREATE(key,msg) \
		if ((key=TlsAlloc())==TLS_OUT_OF_INDEXES) GE_raise_with_message(GE_EX_EXT, msg)
#	define EIF_TSD_SET(key,val,msg) \
		if (!TlsSetValue((key),(EIF_TSD_VAL_TYPE)(val))) GE_raise_with_message(GE_EX_EXT, msg)
#	define EIF_TSD_GET0(val_type,key,val) \
		val=(val_type) TlsGetValue(key)
#	define EIF_TSD_GET(val_type,key,val,msg) \
		EIF_TSD_GET0(val_type,key,val); \
		if (GetLastError() != NO_ERROR) GE_raise_with_message(GE_EX_EXT, msg)
#	define EIF_TSD_DESTROY(key,msg) \
		if (!TlsFree(key)) GE_raise_with_message(GE_EX_EXT, msg)
#endif

/* Key to access Thread Specific Data. */
static EIF_TSD_TYPE GE_thread_context_key;

/*
 * Pointer to current thread.
 */
static EIF_THR_TYPE GE_current_thread(void)
{
#ifdef EIF_POSIX_THREADS
	return pthread_self();
#elif defined EIF_WINDOWS
		/* On Windows, `GetCurrentThread' returns a pseudo handle to the Current thread, */
		/* so we have to do something special on Windows. */
	return OpenThread(THREAD_ALL_ACCESS, FALSE, GetCurrentThreadId());
#endif
}

/*
 * Initialize context of current thread.
 */
static void GE_init_thread_context(GE_context* a_context, GE_thread_context* a_thread_context)
{
	a_thread_context->thread_id = GE_current_thread();
	EIF_TSD_SET(GE_thread_context_key, a_context, "Cannot bind thread context to TSD.");
}

/*
 * Set priority level to thread.
 */
static void GE_thread_set_priority(EIF_THR_TYPE a_thread_id, unsigned int a_priority)
{
#ifdef EIF_POSIX_THREADS
	struct sched_param l_param;
	memset(&l_param, 0, sizeof(struct sched_param));
	l_param.sched_priority = a_priority;
	if (pthread_setschedparam(a_thread_id, SCHED_OTHER, &l_param) != 0) {
		GE_raise_with_message(GE_EX_EXT, "Cannot set priority to thread");
	}
#elif defined(EIF_WINDOWS)
	int l_win_priority;
	switch (a_priority) {
		case EIF_MIN_THR_PRIORITY:
			l_win_priority = THREAD_PRIORITY_LOWEST;
			break;
		case EIF_MAX_THR_PRIORITY:
			l_win_priority = THREAD_PRIORITY_HIGHEST;
			break;
		default:
			if (a_priority <= EIF_BELOW_NORMAL_THR_PRIORITY) {
				l_win_priority = THREAD_PRIORITY_BELOW_NORMAL;
			} else if (a_priority < EIF_ABOVE_NORMAL_THR_PRIORITY) {
				l_win_priority = THREAD_PRIORITY_NORMAL;
			} else {
				l_win_priority = THREAD_PRIORITY_ABOVE_NORMAL;
			}
	}
	if (!SetThreadPriority(a_thread_id, l_win_priority)) {
		GE_raise_with_message(GE_EX_EXT, "Cannot set priority to thread");
	}
#endif
}

/*
 * Routine to be called from the new thread when created.
 */
#ifdef EIF_WINDOWS
static unsigned __stdcall GE_thread_routine(void* arg)
#else
static void* GE_thread_routine(void* arg)
#endif
{
	GE_thread_context* l_thread_context = (GE_thread_context*)arg;
	GE_context l_context = GE_default_context;

	l_context.thread = l_thread_context;
	GE_init_exception(&l_context);
	GE_init_thread_context(&l_context, l_thread_context);
	GE_thread_set_priority(l_thread_context->thread_id, l_thread_context->initial_priority);
	ge_thread_context->routine(l_thread_context->current);
	GE_thread_exit();
#ifdef EIF_WINDOWS
	return 0;
#else
	return NULL;
#endif
}

/*
 * Initialize data to handle threads.
 * To be called at the beginning of the main function.
 */
void GE_init_thread(GE_context* a_context)
{
	GE_thread_context* l_thread_context;

	EIF_TSD_CREATE(GE_thread_context_key, "Cannot create GE_thread_context_key");
	l_thread_context = (GE_thread_context*)GE_unprotected_calloc_uncollectable(1, sizeof(GE_thread_context));
	if (l_thread_context) {
		GE_init_thread_context(l_thread_context);
		a_context->thread = l_thread_context;
	} else {
		GE_raise_with_message(GE_EX_EXT, "Cannot create thread context");
	}
}

/*
 * Create a new thread with attributes `attr' and execute
 * Eiffel routine `routine' on object `current'.
 */
void GE_thread_create_with_attr(EIF_REFERENCE current, void (*routine)(EIF_REFERENCE), EIF_THR_ATTR_TYPE* attr)
{
	EIF_THR_TYPE l_thread_id;
	GE_thread_context* l_thread_context;

	l_thread_context = (GE_thread_context*)GE_unprotected_calloc_uncollectable(1, sizeof(GE_thread_context));
	if (!l_thread_context) {
		GE_raise_with_message(GE_EX_EXT, "Cannot create thread context");
	} else {
		l_thread_context->current = current;
		l_thread_context->routine = routine;
		l_thread_context->initial_priority = attr->priority;
#ifdef EIF_POSIX_THREADS
		{
			pthread_attr_t l_attr;
			int res;

			res = pthread_attr_init(&l_attr);
			if (res == 0) {
					/* Initialize the stack size if more than the minimum. */
				if (thread_attr->stack_size >= PTHREAD_STACK_MIN) {
					pthread_attr_setstacksize(&l_attr, attr->stack_size);
				}
				if (attr->priority != EIF_DEFAULT_THR_PRIORITY) {
					struct sched_param l_param;
					memset(&l_param, 0, sizeof(struct sched_param));
					l_param.sched_priority = attr->priority;
					pthread_attr_setschedpolicy(&l_attr, SCHED_OTHER);
					pthread_attr_setschedparam(&l_attr, &l_param);
				}
					/* We always create threads detached. */
				pthread_attr_setdetachstate(&l_attr, PTHREAD_CREATE_DETACHED);

				res = pthread_create(&l_thread_id, &l_attr, GE_thread_routine, l_thread_context);
				pthread_attr_destroy(&l_attr);
			}
			if (res != 0) {
				GE_free(l_thread_context);
				GE_raise_with_message(GE_EX_EXT, "Cannot create thread");
			}
		}
#elif defined EIF_WINDOWS
		l_thread_id = (EIF_THR_TYPE)_beginthreadex(NULL, (unsigned int)attr->stack_size, GE_thread_routine, l_thread_context, 0, NULL);
		if (l_thread_id == 0) {
			GE_free(l_thread_context);
			GE_raise_with_message(GE_EX_EXT, "Cannot create thread");
		}
#endif
	}
}

/*
 * Execution context of current thread.
 */
GE_context* GE_thread_current_context()
{
	GE_context* volatile l_context;

	EIF_TSD_GET(GE_context*, GE_thread_context_key, l_context, "Cannot get execution context for current thread");
	return l_context;
}

/*
 * Thread ID of current thread.
 */
EIF_POINTER GE_thread_id(void)
{
	GE_context* volatile l_context;

	EIF_TSD_GET(GE_context*, GE_thread_context_key, l_context, "Cannot get execution context for current thread");
	return (EIF_POINTER)(l_context->thread->thread_id);
}

/*
 * Last thread created.
 */
EIF_POINTER GE_last_thread_created(void)
{
/* TODO */
	return NULL;
}

/*
 * Waits until a thread sets `terminated' from `Current' to True,
 * which means it is terminated. The calling thread must be the
 * direct parent of the thread, or the function might loop indefinitely.
 */
void GE_thread_wait(EIF_REFERENCE obj)
{
/* TODO */
}

/*
 * Waits until a thread sets `terminated' from `Current' to True,
 * which means it is terminated, or reaching `a_timeout_ms'.
 * The calling thread must be the direct parent of the thread,
 * or the function might loop indefinitely.
 */
EIF_BOOLEAN GE_thread_wait_with_timeout(EIF_REFERENCE obj, EIF_NATURAL_64 a_timeout_ms)
{
/* TODO */
	return EIF_FALSE;
}

/*
 * Yields execution to other threads.
 */
void GE_thread_yield(void)
{
/* TODO */
}

/*
 * The calling thread waits for all other children threads to terminate.
 */
void GE_thread_join_all(void)
{
/* TODO */
}

/*
 * Function called to terminate a thread launched by Eiffel with `GE_thread_create_with_attr'.
 * This function must be called from the thread itself (not the parent).
 */
void GE_thread_exit(void)
{
	GE_context* volatile l_context;
	EIF_THR_TYPE l_thread_id;

	EIF_TSD_GET(GE_context*, GE_thread_context_key, l_context, "Cannot get execution context for current thread");
	l_thread_id = l_context->thread->thread_id;
	GE_free(l_context->thread);
	GE_free_exception(l_context);
#ifdef EIF_POSIX_THREADS
	pthread_exit(NULL);
#elif defined EIF_WINDOWS
	if (!CloseHandle(l_thread_id)) {
		GE_raise_with_message(GE_EX_EXT, "Cannot close thread");
	}
	_endthreadex(0);
#endif
}

/*
 * Default thread priority level.
 */
EIF_INTEGER GE_thread_default_priority(void)
{
	return EIF_DEFAULT_THR_PRIORITY;
}

/*
 * Minimum thread priority level.
 */
EIF_INTEGER GE_thread_min_priority(void)
{
	return EIF_MIN_THR_PRIORITY;
}

/*
 * Maximum thread priority level.
 */
EIF_INTEGER GE_thread_max_priority(void)
{
	return EIF_MAX_THR_PRIORITY;
}

/*
 * Create a new mutex.
 */
EIF_POINTER GE_mutex_create(void)
{
#ifdef EIF_POSIX_THREAD
	EIF_MUTEX_TYPE* l_mutex;
	int Result;

	l_mutex = (EIF_MUTEX_TYPE*)GE_unprotected_malloc_atomic_uncollectable(sizeof(EIF_MUTEX_TYPE));
	if (l_mutex) {
			/* Make the mutex recursive by default. */
			/* This allows a thread to lock the mutex several times without blocking itself. */
		pthread_mutexattr_t l_attr;
		pthread_mutexattr_init(&l_attr);
		pthread_mutexattr_settype(&l_attr, PTHREAD_MUTEX_RECURSIVE);
		if (!pthread_mutex_init(*l_mutex, &l_attr)) {
			GE_free(l_mutex);
			mutex = NULL;
		}
		pthread_mutexattr_destroy(&l_attr);
	}
	if (!l_mutex) {
		GE_raise_with_message(GE_EX_EXT, "Cannot create mutex");
	}
	return (EIF_POINTER)l_mutex;
#elif defined EIF_WINDOWS
	EIF_CS_TYPE *l_section;

	l_section = (EIF_CS_TYPE*)GE_unprotected_malloc_atomic_uncollectable(sizeof(EIF_CS_TYPE));
	if (l_section) {
		if (!InitializeCriticalSectionAndSpinCount(l_section, (DWORD)4000)) {
			GE_free(l_section);
			l_section = NULL;
		}
	}
	if (!l_section) {
		GE_raise_with_message(GE_EX_EXT, "Cannot create mutex");
	}
	return (EIF_POINTER)l_section;
#else
	return (EIF_POINTER)0;
#endif
}

/*
 * Lock mutex.
 */
void GE_mutex_lock(EIF_POINTER l_mutex)
{
#ifdef EIF_POSIX_THREADS
	if (!pthread_mutex_lock((EIF_MUTEX_TYPE*)l_mutex)) {
		GE_raise_with_message(GE_EX_EXT, "Cannot lock mutex");
	}
#elif defined EIF_WINDOWS
	EnterCriticalSection((EIF_CS_TYPE*)l_mutex);
#endif
}

/*
 * Try to lock mutex. Return True on success.
 */
EIF_BOOLEAN GE_mutex_trylock(EIF_POINTER l_mutex)
{
#ifdef EIF_POSIX_THREADS
	int res;
	res = pthread_mutex_trylock((EIF_MUTEX_TYPE*)l_mutex);
	if (res == EBUSY) {
		return EIF_FALSE;
	} else if (res == 0) {
		return EIF_TRUE;
	} else {
		GE_raise_with_message(GE_EX_EXT, "Cannot lock mutex");
		return EIF_FALSE;
	}
#elif defined EIF_WINDOWS
	if (TryEnterCriticalSection((EIF_CS_TYPE*)l_mutex)) {
		return EIF_TRUE;
	} else {
		return EIF_FALSE;
	}
#else
	return EIF_FALSE;
#endif
}

/*
 * Unlock mutex.
 */
void GE_mutex_unlock(EIF_POINTER l_mutex)
{
#ifdef EIF_POSIX_THREADS
	if (!pthread_mutex_unlock((EIF_MUTEX_TYPE*)l_mutex)) {
		GE_raise_with_message(GE_EX_EXT, "Cannot unlock mutex");
	}
#elif defined EIF_WINDOWS
	LeaveCriticalSection((EIF_CS_TYPE*)l_mutex);
#endif
}

/*
 * Destroy and free all resources used by mutex.
 */
void GE_mutex_destroy(EIF_POINTER l_mutex)
{
	if (l_mutex) {
#ifdef EIF_POSIX_THREADS
		if (!pthread_mutex_destroy((EIF_MUTEX_TYPE*)l_mutex)) {
			GE_raise_with_message(GE_EX_EXT, "Cannot destory mutex");
		}
#elif defined EIF_WINDOWS
		DeleteCriticalSection((EIF_CS_TYPE*)l_mutex);
#endif
		GE_free(l_mutex);
	}
}

#ifdef __cplusplus
}
#endif

#endif
#endif
