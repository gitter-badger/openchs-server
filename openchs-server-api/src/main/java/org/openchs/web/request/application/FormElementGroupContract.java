package org.openchs.web.request.application;

import com.fasterxml.jackson.annotation.JsonInclude;
import org.openchs.web.request.ReferenceDataContract;

import java.util.ArrayList;
import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class FormElementGroupContract extends ReferenceDataContract {
    private Double displayOrder;
    private String display;
    private List<FormElementContract> formElements;
    private Long organisationId;

    public FormElementGroupContract() {
    }

    public FormElementGroupContract(String uuid, String userUUID, String name, Double displayOrder) {
        super(uuid, userUUID, name);
        this.displayOrder = displayOrder;
        formElements = new ArrayList<>();
    }

    public Double getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(Double displayOrder) {
        this.displayOrder = displayOrder;
    }

    public List<FormElementContract> getFormElements() {
        return formElements;
    }

    public void setFormElements(List<FormElementContract> formElements) {
        this.formElements = formElements;
    }

    public void addFormElement(FormElementContract formElementContract) {
        this.formElements.add(formElementContract);
    }

    public String getDisplay() {
        return display;
    }

    public void setDisplay(String display) {
        this.display = display;
    }

    @Override
    public String toString() {
        return "{" +
                "name=" + this.getName() + '\'' +
                "displayOrder=" + displayOrder +
                ", display='" + display + '\'' +
                '}';
    }

    public void setOrganisationId(Long organisationId) {
        this.organisationId = organisationId;
    }

    public Long getOrganisationId() {
        return organisationId;
    }
}