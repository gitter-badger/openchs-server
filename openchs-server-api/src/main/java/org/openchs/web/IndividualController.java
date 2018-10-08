package org.openchs.web;

import org.joda.time.DateTime;
import org.openchs.dao.GenderRepository;
import org.openchs.dao.IndividualRepository;
import org.openchs.dao.LocationRepository;
import org.openchs.domain.AddressLevel;
import org.openchs.domain.Gender;
import org.openchs.domain.Individual;
import org.openchs.service.ObservationService;
import org.openchs.service.UserService;
import org.openchs.web.request.IndividualRequest;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.hateoas.Link;
import org.springframework.hateoas.PagedResources;
import org.springframework.hateoas.Resource;
import org.springframework.hateoas.ResourceProcessor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.transaction.Transactional;

@RestController
public class IndividualController extends AbstractController<Individual> implements RestControllerResourceProcessor<Individual> {
    private final IndividualRepository individualRepository;
    private final LocationRepository locationRepository;
    private final GenderRepository genderRepository;
    private ObservationService observationService;
    private UserService userService;

    private static org.slf4j.Logger logger = LoggerFactory.getLogger(IndividualController.class);

    @Autowired
    public IndividualController(IndividualRepository individualRepository, LocationRepository locationRepository, GenderRepository genderRepository, ObservationService observationService, UserService userService) {
        this.individualRepository = individualRepository;
        this.locationRepository = locationRepository;
        this.genderRepository = genderRepository;
        this.observationService = observationService;
        this.userService = userService;
    }

    @RequestMapping(value = "/individuals", method = RequestMethod.POST)
    @Transactional
    @PreAuthorize(value = "hasAnyAuthority('user', 'admin')")
    public void save(@RequestBody IndividualRequest individualRequest) {
        logger.info(String.format("Saving individual with UUID %s", individualRequest.getUuid()));

        Individual individual = createIndividualWithoutObservations(individualRequest);
        individual.setObservations(observationService.createObservations(individualRequest.getObservations()));
        individualRepository.save(individual);
        logger.info(String.format("Saved individual with UUID %s", individualRequest.getUuid()));
    }

    @RequestMapping(value = "/individual/search/byCatchmentAndLastModified", method = RequestMethod.GET)
    @PreAuthorize(value = "hasAnyAuthority('user', 'admin')")
    public PagedResources<Resource<Individual>> getIndividualsByCatchmentAndLastModified(
            @RequestParam("catchmentId") long catchmentId,
            @RequestParam("lastModifiedDateTime") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) DateTime lastModifiedDateTime,
            @RequestParam("now") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) DateTime now,
            Pageable pageable) {
        return wrap(individualRepository.findByAddressLevelVirtualCatchmentsIdAndAuditLastModifiedDateTimeIsBetweenOrderByAuditLastModifiedDateTimeAscIdAsc(catchmentId, lastModifiedDateTime, now, pageable));
    }

    @RequestMapping(value = "/individual/search/lastModified", method = RequestMethod.GET)
    @PreAuthorize(value = "hasAnyAuthority('user', 'admin')")
    public PagedResources<Resource<Individual>> getIndividualsByLastModified(
            @RequestParam("lastModifiedDateTime") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) DateTime lastModifiedDateTime,
            @RequestParam("now") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) DateTime now,
            Pageable pageable) {
        return wrap(individualRepository.findByAuditLastModifiedDateTimeIsBetweenAndIsVoidedFalseOrderByAuditLastModifiedDateTimeAscIdAsc(lastModifiedDateTime, now, pageable));
    }

    @Override
    public void process(Resource<Individual> resource) {
        Individual individual = resource.getContent();
        resource.removeLinks();
        resource.add(new Link(individual.getAddressLevel().getUuid(), "addressUUID"));
        resource.add(new Link(individual.getGender().getUuid(), "genderUUID"));
    }

    private Individual createIndividualWithoutObservations(@RequestBody IndividualRequest individualRequest) {
        AddressLevel addressLevel = getAddressLevel(individualRequest);
        Gender gender = individualRequest.getGender() == null ? genderRepository.findByUuid(individualRequest.getGenderUUID()) : genderRepository.findByName(individualRequest.getGender());
        Individual individual = newOrExistingEntity(individualRepository, individualRequest, new Individual());
        individual.setFirstName(individualRequest.getFirstName());
        individual.setLastName(individualRequest.getLastName());
        individual.setDateOfBirth(individualRequest.getDateOfBirth());
        individual.setAddressLevel(addressLevel);
        individual.setGender(gender);
        individual.setRegistrationDate(individualRequest.getRegistrationDate());
        individual.setVoided(individualRequest.isVoided());
        individual.setFacility(userService.getUserFacility());
        return individual;
    }

    private AddressLevel getAddressLevel(@RequestBody IndividualRequest individualRequest) {
        if (individualRequest.getAddressLevelUUID() != null) {
            return locationRepository.findByUuid(individualRequest.getAddressLevelUUID());
        } else if (individualRequest.getCatchmentUUID() != null) {
            return locationRepository.findByTitleAndCatchmentsUuid(individualRequest.getAddressLevel(), individualRequest.getCatchmentUUID());
        } else {
            return locationRepository.findByTitleIgnoreCase(individualRequest.getAddressLevel());
        }
    }
}