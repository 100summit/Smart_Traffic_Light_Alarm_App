package com.summit.hackerton.utils

import timber.log.Timber

/**
 * setting timber log tree
 *
 * @author Brand
 * @since 2023/03/14
 **/
class TimberLogTree(private val prefix: String) : Timber.DebugTree() {
    /**
     * set log format
     *
     * @author Brand
     * @since 2023/03/14
     **/
    override fun createStackElementTag(element: StackTraceElement): String =
        "$prefix: " +
                "(${element.fileName}:${element.lineNumber}) " +
                "[${element.methodName}]"
}