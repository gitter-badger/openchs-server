DROP VIEW IF EXISTS mother_program_enrolments;
DROP VIEW IF EXISTS mother_program_encounters;
DROP VIEW IF EXISTS adolescent_visit_summary;
DROP VIEW IF EXISTS adolescents;
DROP VIEW IF EXISTS adolescent_visit;
DROP VIEW IF EXISTS checklist_items;
DROP VIEW IF EXISTS boolean;

-- <RCH>
CREATE OR REPLACE VIEW mother_program_enrolments AS
  SELECT
    individual.id                                                                     individual,
    min(catchment.id)                                                                 catchment,
    program_enrolment.id                                                              enrolment,
    program_enrolment.enrolment_date_time                                             internal_enrolment_date,
    to_char(program_enrolment.enrolment_date_time, 'DD-Mon-YYYY')                     enrolment_date,
    program_enrolment.program_exit_date_time                                          internal_exit_date,
    to_char(program_enrolment.program_exit_date_time, 'DD-Mon-YYYY')                  exit_date,
    individual.date_of_birth                                                          internal_date_of_birth,
    to_char(individual.date_of_birth, 'DD-Mon-YYYY')                                  date_of_birth,
    min(address_level.id)                                                             address,
    to_char(date_obs(program_enrolment, 'Last Menstrual Period'), 'DD-Mon-YYYY')      LMP,
    date_obs(program_enrolment, 'Estimated Date of Delivery')                         internal_edd,
    to_char(date_obs(program_enrolment, 'Estimated Date of Delivery'), 'DD-Mon-YYYY') EDD,
    coded_obs_exists(program_enrolment, 'High Risk Conditions')                       is_high_risk,
    coded_obs(program_enrolment, 'High Risk Conditions')                              high_risk_conditions,
    count(program_encounter)                                                          number_of_visits,
    sum(is_overdue_visit(program_encounter))                                          number_of_overdue_visits
  FROM program_enrolment
    INNER JOIN program p ON program_enrolment.program_id = p.id AND p.name = 'Mother'
    INNER JOIN individual ON program_enrolment.individual_id = individual.id
    INNER JOIN address_level ON address_level.id = individual.address_id
    INNER JOIN catchment_address_mapping ON catchment_address_mapping.addresslevel_id = address_level.id
    INNER JOIN catchment ON catchment_address_mapping.catchment_id = catchment.id
    LEFT OUTER JOIN program_encounter ON program_enrolment.id = program_encounter.program_enrolment_id
  GROUP BY individual.id, program_enrolment.id;

CREATE OR REPLACE VIEW mother_program_encounters AS
  SELECT
    individual.id                                                                     individual,
    to_char(individual.date_of_birth, 'DD-Mon-YYYY')                                  date_of_birth,
    individual.date_of_birth                                                          internal_date_of_birth,
    address_level.id                                                                  address,
    program_enrolment.id                                                              enrolment_id,
    program_enrolment.enrolment_date_time                                             internal_enrolment_date,
    to_char(program_enrolment.enrolment_date_time, 'DD-Mon-YYYY')                     enrolment_date,
    to_char(date_obs(program_enrolment, 'Last Menstrual Period'), 'DD-Mon-YYYY')      LMP,
    to_char(date_obs(program_enrolment, 'Estimated Date of Delivery'), 'DD-Mon-YYYY') EDD,
    program_encounter.id                                                              visit,
    program_encounter.earliest_visit_date_time                                        internal_earliest_visit_date,
    to_char(program_encounter.earliest_visit_date_time, 'DD-Mon-YYYY')                earliest_visit_date,
    program_encounter.max_visit_date_time                                             internal_max_visit_date,
    to_char(program_encounter.max_visit_date_time, 'DD-Mon-YYYY')                     max_visit_date,
    encounter_type.id                                                                 visit_type,
    program_encounter.name                                                            visit_name,
    program_encounter.encounter_date_time                                             internal_visit_date,
    to_char(program_encounter.encounter_date_time, 'DD-Mon-YYYY')                     visit_date,
    coded_obs_exists(program_enrolment, 'High Risk Conditions')                       is_high_risk,
    coded_obs(program_enrolment, 'High Risk Conditions')                              high_risk_conditions,
    catchment.id                                                                      catchment
  FROM program_encounter
    INNER JOIN program_enrolment ON program_encounter.program_enrolment_id = program_enrolment.id
    INNER JOIN program p ON program_enrolment.program_id = p.id AND p.name = 'Mother'
    INNER JOIN encounter_type ON program_encounter.encounter_type_id = encounter_type.id
    INNER JOIN individual ON program_enrolment.individual_id = individual.id
    INNER JOIN address_level ON address_level.id = individual.address_id
    INNER JOIN catchment_address_mapping ON catchment_address_mapping.addresslevel_id = address_level.id
    INNER JOIN catchment ON catchment_address_mapping.catchment_id = catchment.id;
-- </RCH>

-- <Adolescent>
CREATE OR REPLACE VIEW adolescents AS
  SELECT
    individual.id                                                 individual,
    gender.name                                                   gender,
    catchment.type                                                catchment_type,
    address_level.id                                              address_level,
    address_level.type_id                                          address_level_type,
    program_enrolment.id                                          enrolment_id,
    program_enrolment.enrolment_date_time                         internal_enrolment_date,
    to_char(program_enrolment.enrolment_date_time, 'DD-Mon-YYYY') enrolment_date
  FROM individual
    INNER JOIN gender ON individual.gender_id = gender.id
    INNER JOIN address_level ON individual.address_id = address_level.id
    INNER JOIN catchment_address_mapping ON address_level.id = catchment_address_mapping.addresslevel_id
    INNER JOIN catchment ON catchment.id = catchment_address_mapping.catchment_id
    LEFT OUTER JOIN program_enrolment ON individual.id = program_enrolment.individual_id
    LEFT OUTER JOIN program ON program_enrolment.program_id = program.id
  WHERE program.name = 'Adolescent';


CREATE OR REPLACE VIEW adolescent_visit AS
  SELECT
    individual.id                                                 individual,
    gender.name                                                   gender,
    catchment.type                                                catchment_type,
    program_enrolment.id                                          enrolment_id,
    program_enrolment.enrolment_date_time                         internal_enrolment_date,
    to_char(program_enrolment.enrolment_date_time, 'DD-Mon-YYYY') enrolment_date,
    program_encounter.id                                          program_encounter,
    program_encounter.encounter_date_time                         visit_date
  FROM individual
    INNER JOIN gender ON individual.gender_id = gender.id
    INNER JOIN address_level ON individual.address_id = address_level.id
    INNER JOIN catchment_address_mapping ON address_level.id = catchment_address_mapping.addresslevel_id
    INNER JOIN catchment ON catchment.id = catchment_address_mapping.catchment_id
    LEFT OUTER JOIN program_enrolment ON individual.id = program_enrolment.individual_id
    LEFT OUTER JOIN program_encounter ON program_enrolment.id = program_encounter.program_enrolment_id
    LEFT OUTER JOIN program ON program_enrolment.program_id = program.id
  WHERE program.name = 'Adolescent';


CREATE OR REPLACE VIEW virtual_catchment_address_mapping_table AS (
  WITH RECURSIVE intermediary_table AS (
      SELECT
        c.id   cid,
        al1.id aid,
        al2.id parent_id
      FROM address_level al1
        LEFT OUTER JOIN location_location_mapping llm ON al1.id = llm.location_id
        LEFT OUTER JOIN address_level al2 ON llm.parent_location_id = al2.id
        LEFT OUTER JOIN catchment_address_mapping cam ON cam.addresslevel_id = al1.id
        LEFT OUTER JOIN catchment c ON cam.catchment_id = c.id
  ), vt AS (
    SELECT
      cid,
      aid,
      parent_id
    FROM intermediary_table
    UNION ALL
    SELECT
      vt.cid,
      it.aid,
      it.parent_id
    FROM intermediary_table it, vt
    WHERE vt.aid = it.parent_id
  ) SELECT
      row_number()
      OVER () AS id,
      cid     AS catchment_id,
      aid     AS addresslevel_id
    FROM vt
    WHERE cid IS NOT NULL
    GROUP BY cid, aid
);

drop view if exists latest_program_encounter CASCADE;
create view latest_program_encounter as
  with latest_on_top as (
    with encounter as (
        select encounter.*,
               enrolment.individual_id                                             individual_id,
               coalesce(encounter.encounter_date_time, encounter.cancel_date_time) effective_date,
               et.name                                                             encounter_type_name
        from program_encounter encounter
               join encounter_type et on encounter_type_id = et.id
               join program_enrolment enrolment on enrolment.id = encounter.program_enrolment_id
    )
    select encounter.*, row_number() OVER (PARTITION BY individual_id ORDER BY effective_date desc) rank
    from encounter
    where effective_date is not null
  )
  select * from latest_on_top where rank = 1;

CREATE OR REPLACE VIEW address_level_type_view AS
  WITH RECURSIVE list_of_orgs(id,
      parent_organisation_id) AS (SELECT id, parent_organisation_id
                                  FROM organisation
                                  WHERE db_user = current_user
                                  UNION ALL SELECT o.id, o.parent_organisation_id
                                            FROM organisation o,
                                                 list_of_orgs log
                                            WHERE o.id = log.parent_organisation_id)
  SELECT al.*, alt.name as "type"
  from address_level al
         inner join address_level_type alt on al.type_id = alt.id
         inner join list_of_orgs loo on loo.id=al.organisation_id
  where alt.is_voided is not true;



CREATE OR REPLACE VIEW coded_concept AS
select c2.id as id, c2.name as name, string_agg(c1.name, ', ') as answers
from concept_answer ca
       inner join concept c1 on ca.answer_concept_id = c1.id
       inner join concept c2 on ca.concept_id = c2.id
GROUP BY c2.id;

CREATE VIEW boolean AS
(select 'Yes' as status
 union
select 'No' as status);