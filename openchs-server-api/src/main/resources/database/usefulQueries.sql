-- ORGANISATION DATA
---- Organisations and their parent
select *
from (select
        o1.id      parent_organisation_id,
        o1.name    parent_organisation_name,
        o1.db_user parent_organisation_db_user,
        o2.id      organisation_id,
        o2.name    organisation_name,
        o2.db_user organisation_db_user
      from organisation o1
        left outer join organisation o2 on o1.id = o2.parent_organisation_id) X
where parent_organisation_name = 'OpenCHS' or organisation_name is not null;

---- Organisation with address and catchment
select
  o.id organisation_id,
  c2.id catchment_id,
  c2.name catchment_name,
  address_level.id address_level_id,
  address_level.title address_level_title
from address_level
  inner join catchment_address_mapping m2 on address_level.id = m2.addresslevel_id
  inner join catchment c2 on m2.catchment_id = c2.id
  inner join organisation o on c2.organisation_id = o.id
where o.name = ?
order by c2.name;

-- ITEMS FOR TRANSLATION
select distinct name
from
  (
    select form_element_group_name as name
    from all_form_element_groups
    where organisation_id = :organisation_id
    union
    select form_element_name as name
    from all_form_elements
    where organisation_id = :organisation_id
    union
    select concept_name as name
    from all_concepts
    where organisation_id = :organisation_id
    union
    select answer_concept_name as name
    from all_concept_answers
    where organisation_id = :organisation_id
    union
    select operational_encounter_type_name as name
    from all_operational_encounter_types
    where organisation_id = :organisation_id
    union
    select encounter_type_name as name
    from all_encounter_types
    where organisation_id = :organisation_id
    union
    select operational_program_name as name
    from all_operational_programs
    where organisation_id = :organisation_id
    union
    select program_name as name
    from all_programs
    where organisation_id = :organisation_id
    union
    select name
    from checklist_detail
    where organisation_id = :organisation_id
    union
    select type as name
    from catchment
    where organisation_id = :organisation_id
    union
    select title as name
    from address_level
    where organisation_id = :organisation_id

    union

    select concept.name as name
    from concept
    where
      concept.id not in (select concept.id
                         from concept
                           inner join form_element element2 on concept.id = element2.concept_id
                         where concept.organisation_id = :organisation_id
                         union
                         select concept.id
                         from concept
                           inner join concept_answer ca on concept.id = ca.answer_concept_id
                         where concept.organisation_id = :organisation_id) and
      concept.organisation_id = :organisation_id and not concept.is_voided

    union

    select concept.name concept_name
    from concept
    where concept.id not in (select concept.id
                             from concept
                               inner join form_element element2 on concept.id = element2.concept_id
                             where concept.organisation_id = 1
                             union
                             select concept.id
                             from concept
                               inner join concept_answer ca on concept.id = ca.answer_concept_id
                             where concept.organisation_id = 1
    ) and concept.organisation_id = 1 and not concept.is_voided
  ) as X
order by name;

-- VIEW CONCEPT WITH ANSWERS
select
  concept.name,
  a.uuid  AS "Concept Answer UUID",
  c2.uuid as "Answer UUID",
  c2.name as "Answer",
  a.answer_order,
  a.organisation_id map_organisation_id,
  concept.organisation_id q_organisation_id,
  c2.organisation_id ans_organisation_id
from concept
  inner join concept_answer a on concept.id = a.concept_id
  inner join concept c2 on a.answer_concept_id = c2.id
where concept.uuid = '58b6367a-825f-43e2-b6b7-b35a5cbc3a09'
order by a.answer_order;


-- GET ALL THE FORM ELEMENTS AND CONCEPT (WITHOUT ANSWERS) IN AN ORG - (Required for translations, do not change this one)
select
  p.name,
  f.name  as FormName
  -- ,fm.entity_id
  -- ,fm.observations_type_entity_id
  -- ,fm.organisation_id
  ,
  feg.name,
  fe.name as "Form Element",
  c2.name as "Concept",
   f.organisation_id as "Organisation Id",
       fe.is_voided as "Form Element Voided"
from operational_program p
  inner join form_mapping fm on (fm.entity_id = p.program_id)
  inner join form f on fm.form_id = f.id
  inner join form_element_group feg on feg.form_id = f.id
  inner join form_element fe on fe.form_element_group_id = feg.id
  inner join concept c2 on fe.concept_id = c2.id
where p.organisation_id = ?1 and f.form_type != 'ProgramEncounterCancellation' and fe.id not in (select form_element_id
                                                                                                from non_applicable_form_element
                                                                                                where organisation_id = ?1)
order by
  f.name
  , feg.display_order asc
  , fe.display_order asc;


-- GET ALL DETAILS OF A FORM
select
--   feg.name form_element_group_name,
  fe.name as form_element_name,
  c.name as concept_name,
  c.data_type concept_data_type,
  ac.name as answer_concept_name
from form f
  inner join form_element_group feg on feg.form_id = f.id
  inner join form_element fe on fe.form_element_group_id = feg.id
  inner join concept c on fe.concept_id = c.id
  left outer join concept_answer ca on c.id = ca.concept_id
  left outer join concept ac on ca.answer_concept_id = ac.id
where f.name = ? and fe.id not in (select form_element_id from non_applicable_form_element where organisation_id = ?) and c.uuid != 'b4e5a662-97bf-4846-b9b7-9baeab4d89c4'
order by
  feg.display_order asc
  ,fe.display_order asc
  ,ca.answer_order;

-- Concept with answers
select q.name, string_agg(a.name,E'\n' order by ca.answer_order)
from concept_answer ca
inner join concept a on ca.answer_concept_id = a.id
inner join concept q on ca.concept_id = q.id
group by q.name;
---------------

------- form->form element groups->form elements->concept->answers
select
  f.name  as FormName,
  feg.name as FormElementGroup,
  fe.name as FormElement,
  co.name as ConceptOwn,
  feo.name as FormElementOwn,
  c.name as Concept,
  coalesce(ca.answers, '<'||c.data_type||'>') as Answers
from form f
  inner join form_element_group feg on feg.form_id = f.id
  inner join form_element fe on fe.form_element_group_id = feg.id
  inner join concept c on fe.concept_id = c.id
  inner join organisation co on co.id = c.organisation_id
  inner join organisation feo on feo.id = fe.organisation_id
  left join (
          select ca.concept_id, string_agg(a.name,E'\n' order by ca.answer_order) answers
          from concept_answer ca inner join concept a on ca.answer_concept_id = a.id
          group by ca.concept_id
      ) ca on ca.concept_id = c.id
  left join non_applicable_form_element rem on rem.form_element_id = fe.id and rem.is_voided <> TRUE and rem.organisation_id = ?
where rem.id is null and f.name = ?
order by
  f.name
  , feg.display_order asc
  , fe.display_order asc;
--------------

-- Get all the REGISTRATION form elements and concept (without answers) for translation
select
  f.name  as FormName
  -- ,fm.entity_id
  -- ,fm.observations_type_entity_id
  -- ,fm.organisation_id
  ,
  feg.name,
  fe.name as "Form Element",
  c2.name as "Concept"
from form f
  inner join form_element_group feg on feg.form_id = f.id
  inner join form_element fe on fe.form_element_group_id = feg.id
  inner join concept c2 on fe.concept_id = c2.id
where f.organisation_id = 9 and f.form_type = 'IndividualProfile'
order by
  f.name
  , feg.display_order asc
  , fe.display_order asc;

-- Get Programs
select
  operational_program.name,
  p.name
from operational_program
  inner join program p on operational_program.program_id = p.id
where operational_program.organisation_id = :org_name;

-- Encounter types
select
  et.name  "EncounterType",
  oet.name "OrgEncounterType"
from operational_encounter_type oet
  inner join encounter_type et on oet.encounter_type_id = et.id;

-- Program with its encounter types
select
  distinct
  operational_program.name operational_program_name,
  p.name program_name,
  form.id form_id,
  form.name form_name,
  encounter_type.name encouter_type_name
from operational_program
  inner join program p on operational_program.program_id = p.id
  inner join form_mapping on form_mapping.entity_id = p.id
  inner join form on form_mapping.form_id = form.id
  left outer join encounter_type on encounter_type.id = form_mapping.observations_type_entity_id
where operational_program.organisation_id = ?
order by operational_program_name, program_name, form_name;


-- Cancel Forms
select
  f2.id               as FormMappingId,
  program.name        as Program,
  encounter_type.name as EncounterType
from form f
  inner join form_mapping f2 on f.id = f2.form_id
  inner join encounter_type on encounter_type.id = f2.observations_type_entity_id
  inner join program on program.id = f2.entity_id
where f2.organisation_id = 2 and f.form_type = 'ProgramEncounterCancellation'
order by
  Program;


select
  i.id,
  audit.last_modified_date_time
from address_level
  inner join catchment_address_mapping m2 on address_level.id = m2.addresslevel_id
  inner join individual i on address_level.id = i.address_id
  inner join catchment on catchment.id = m2.catchment_id
  inner join program_enrolment on i.id = program_enrolment.individual_id
  inner join audit on audit.id = i.audit_id
where m2.catchment_id = 2
order by audit.last_modified_date_time desc;


select distinct i.id
from address_level
  inner join catchment_address_mapping m2 on address_level.id = m2.addresslevel_id
  inner join individual i on address_level.id = i.address_id
  inner join catchment on catchment.id = m2.catchment_id
  left outer join program_enrolment on i.id = program_enrolment.individual_id
where m2.catchment_id = 2 and program_enrolment.id is null;


-- Queries to test and fix the audit last_modified_by updating with wrong user issue. Card #982 will provide a solution.
-- Query to run after implementation deployment. The count is desired to be 0
select count(a.id) from form_element x
  inner join audit a on x.audit_id = a.id
where x.organisation_id = 1 and a.last_modified_by_id != 1;

-- Query to fix
update audit set last_modified_by_id = 1 where id in (select a.id from form_element x
  inner join audit a on x.audit_id = a.id
where x.organisation_id = 1 and a.last_modified_by_id != 1
);