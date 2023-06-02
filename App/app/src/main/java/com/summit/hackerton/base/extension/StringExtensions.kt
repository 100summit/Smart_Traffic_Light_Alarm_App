package com.summit.hackerton.base.extension

/**
 * String Extensions
 *
 * @author Brand
 * @created 2023-05-22
 **/
fun String.isJsonObject(): Boolean = !isNullOrEmpty() && startsWith("{") && endsWith("}")

fun String.isJsonArray(): Boolean = !isNullOrEmpty() && startsWith("[") && endsWith("]")

fun String.isJson() = isJsonObject() || isJsonArray()