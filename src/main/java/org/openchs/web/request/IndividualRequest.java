package org.openchs.web.request;

import org.joda.time.LocalDate;

public class IndividualRequest extends CHSRequest {
    private String name;
    private LocalDate dateOfBirth;
    private boolean dateOfBirthVerified;
    private String genderUUID;
    private String addressLevelUUID;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public LocalDate getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(LocalDate dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public boolean isDateOfBirthVerified() {
        return dateOfBirthVerified;
    }

    public void setDateOfBirthVerified(boolean dateOfBirthVerified) {
        this.dateOfBirthVerified = dateOfBirthVerified;
    }

    public String getGenderUUID() {
        return genderUUID;
    }

    public void setGenderUUID(String genderUUID) {
        this.genderUUID = genderUUID;
    }

    public String getAddressLevelUUID() {
        return addressLevelUUID;
    }

    public void setAddressLevelUUID(String addressLevelUUID) {
        this.addressLevelUUID = addressLevelUUID;
    }
}