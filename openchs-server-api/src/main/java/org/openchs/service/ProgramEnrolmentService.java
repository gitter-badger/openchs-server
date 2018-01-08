package org.openchs.service;

import org.joda.time.DateTime;
import org.openchs.dao.ProgramEnrolmentRepository;
import org.openchs.domain.ProgramEncounter;
import org.openchs.domain.ProgramEnrolment;
import org.springframework.stereotype.Service;

@Service
public class ProgramEnrolmentService {
    private ProgramEnrolmentRepository programEnrolmentRepository;

    public ProgramEnrolmentService(ProgramEnrolmentRepository programEnrolmentRepository) {
        this.programEnrolmentRepository = programEnrolmentRepository;
    }

    public ProgramEncounter matchingEncounter(String programEnrolmentUUID, String encounterTypeName, DateTime encounterDateTime) {
        ProgramEnrolment programEnrolment = programEnrolmentRepository.findByUuid(programEnrolmentUUID);
        return programEnrolment.getProgramEncounters().stream().filter(programEncounter -> programEncounter.getEncounterType().getName().equals(encounterTypeName) && programEncounter.dateFallsWithIn(encounterDateTime)).findAny().orElse(null);
    }
}