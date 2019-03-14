package edu.gmu.css.service;

import org.neo4j.ogm.typeconversion.AttributeConverter;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;


public class DateConverter implements AttributeConverter<Long, LocalDate> {

    @Override
    public LocalDate toGraphProperty(Long value) {
        LocalDate start = LocalDate.of(1815, 1, 1);
        LocalDate date = start.plusWeeks(value.intValue());
        return date;
    }

    @Override
    public Long toEntityAttribute(LocalDate value) {
        LocalDate zero = LocalDate.of(1815,1,1);
        return ChronoUnit.WEEKS.between(zero, value);
    }

}