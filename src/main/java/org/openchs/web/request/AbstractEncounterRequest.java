package org.openchs.web.request;

import org.joda.time.DateTime;
import java.util.List;

public class AbstractEncounterRequest extends CHSRequest {
    private DateTime encounterDateTime;
    private String encounterTypeUUID;
    private List<ObservationRequest> observations;

    public DateTime getEncounterDateTime() {
        return encounterDateTime;
    }

    public void setEncounterDateTime(DateTime encounterDateTime) {
        this.encounterDateTime = encounterDateTime;
    }

    public String getEncounterTypeUUID() {
        return encounterTypeUUID;
    }

    public void setEncounterTypeUUID(String encounterTypeUUID) {
        this.encounterTypeUUID = encounterTypeUUID;
    }

    public List<ObservationRequest> getObservations() {
        return observations;
    }

    public void setObservations(List<ObservationRequest> observations) {
        this.observations = observations;
    }
}