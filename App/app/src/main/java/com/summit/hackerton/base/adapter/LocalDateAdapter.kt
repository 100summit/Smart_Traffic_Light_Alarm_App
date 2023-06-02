package com.summit.hackerton.base.adapter

import com.google.gson.*
import java.lang.reflect.Type
import java.time.LocalDate
import java.time.format.DateTimeFormatter

/**
 * API Log 분석에 사용
 *
 * @author Brand
 * @created 2023-05-22
 **/
class LocalDateAdapter : JsonSerializer<LocalDate>, JsonDeserializer<LocalDate> {
    @Throws(JsonParseException::class)
    override fun deserialize(json: JsonElement, typeOfT: Type, context: JsonDeserializationContext): LocalDate {
        return LocalDate.parse(json.asString, DateTimeFormatter.ISO_LOCAL_DATE)
    }

    override fun serialize(date: LocalDate, typeOfSrc: Type, context: JsonSerializationContext): JsonElement {
        return JsonPrimitive(date.format(DateTimeFormatter.ISO_LOCAL_DATE))
    }
}