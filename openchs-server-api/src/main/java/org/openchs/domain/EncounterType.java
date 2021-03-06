package org.openchs.domain;

import javax.persistence.*;
import javax.validation.constraints.NotNull;

@Entity
@Table(name = "encounter_type")
public class EncounterType extends OrganisationAwareEntity {
    @NotNull
    @Column
    private String name;

    @ManyToOne(fetch=FetchType.LAZY)
    @JoinColumn(name="concept_id")
    private Concept concept;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Concept getConcept() {
        return concept;
    }

    public void setConcept(Concept concept) {
        this.concept = concept;
    }

    public static EncounterType create(String name) {
        EncounterType encounterType = new EncounterType();
        encounterType.setName(name);
        return encounterType;
    }
}