package org.openchs.dao;

import org.openchs.domain.Catchment;
import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Repository;

@Repository
@RepositoryRestResource(collectionResourceRel = "catchment", path = "catchment")
public interface CatchmentRepository extends ReferenceDataRepository<Catchment>, FindByLastModifiedDateTime<Catchment> {
}