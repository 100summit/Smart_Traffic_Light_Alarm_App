package com.summit.hackerton.base.adapter

import com.google.gson.*
import java.lang.reflect.Type
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

/**
 * API Log 분석에 사용
 *
 * @author Brand
 * @created 2023-05-22
 **/
class LocalDateTimeAdapter : JsonSerializer<LocalDateTime?>, JsonDeserializer<LocalDateTime?> {
    @Throws(JsonParseException::class)
    override fun deserialize(json: JsonElement, typeOfT: Type?, context: JsonDeserializationContext?): LocalDateTime {
        return LocalDateTime.parse(json.asString, DateTimeFormatter.ISO_LOCAL_DATE_TIME)
    }

    override fun serialize(localDateTime: LocalDateTime?, typeOfSrc: Type?, context: JsonSerializationContext?): JsonElement {
        return JsonPrimitive(DateTimeFormatter.ISO_LOCAL_DATE_TIME.format(localDateTime))
    }
}