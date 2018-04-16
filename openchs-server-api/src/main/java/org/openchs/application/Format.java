package org.openchs.application;

import org.openchs.web.request.FormatContract;

import javax.persistence.Column;
import javax.persistence.Embeddable;
import javax.validation.constraints.NotNull;

@Embeddable
public class Format {

    @Column(name = "valid_format_regex", nullable = false)
    private String regex;

    @Column(name = "valid_format_description_key", nullable = false)
    private String descriptionKey;

    public Format(String regex, String descriptionKey){
        this.regex = regex;
        this.descriptionKey = descriptionKey;
    }

    public String getRegex() {
        return regex;
    }

    public void setRegex(String regex) {
        this.regex = regex;
    }

    public String getDescriptionKey() {
        return descriptionKey;
    }

    public void setDescriptionKey(String descriptionKey) {
        this.descriptionKey = descriptionKey;
    }
}
