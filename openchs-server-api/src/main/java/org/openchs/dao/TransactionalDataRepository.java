package org.openchs.dao;

import org.openchs.domain.CHSEntity;
import org.springframework.data.repository.NoRepositoryBean;
import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.security.access.prepost.PreAuthorize;

@NoRepositoryBean
@PreAuthorize(value = "hasAnyAuthority('user')")
public interface TransactionalDataRepository<T extends CHSEntity> extends CHSRepository<T>, PagingAndSortingRepository<T, Long> {

}
