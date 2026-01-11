{{
    config(
        materialized='view'
    )
}}

/*
    Filters prescriptions for antibiotics that can be used for Sepsis-3 computation.
    
    Based on the following sql script by Alistair Johnson and Tom Pollard:
    https://github.com/alistairewj/sepsis3-mimic/blob/master/query/tbls/abx-poe-list.sql
    
    Exclusions:
    - Routes via eye, ear, or topical administration
    - Null drug names
    - Null hospital admission IDs
*/

with prescriptions as (
    select
        subject_id,
        hadm_id,
        starttime as charttime,
        lower(drug) as drug,
        lower(route) as route
    from {{ ref('stg_hosp__prescriptions') }}
    where drug is not null
      and hadm_id is not null
      and starttime is not null
),

-- List of antibiotic drug names (lowercase) for Sepsis-3 criteria
antibiotic_drugs as (
    select lower(drug_name) as drug_name
    from (
        values
            ('cefazolin'),
            ('piperacillin-tazobactam'),
            ('vancomycin'),
            ('sulfameth/trimethoprim ds'),
            ('levofloxacin'),
            ('sulfameth/trimethoprim ss'),
            ('amoxicillin-clavulanic acid'),
            ('aztreonam'),
            ('azithromycin '),
            ('metronidazole (flagyl)'),
            ('piperacillin-tazobactam na'),
            ('ampicillin-sulbactam'),
            ('doxycycline hyclate'),
            ('nitrofurantoin monohyd (macrobid)'),
            ('cefepime'),
            ('ceftazidime'),
            ('amoxicillin'),
            ('clarithromycin'),
            ('azithromycin'),
            ('ciprofloxacin hcl'),
            ('tobramycin sulfate'),
            ('clindamycin'),
            ('cephalexin'),
            ('metronidazole'),
            ('ampicillin sodium'),
            ('ciprofloxacin iv'),
            ('vancomycin intraventricular'),
            ('vancomycin oral liquid'),
            ('cefpodoxime proxetil'),
            ('gentamicin'),
            ('nitrofurantoin (macrodantin)'),
            ('vancomycin enema'),
            ('amoxicillin oral susp.'),
            ('clindamycin solution'),
            ('minocycline'),
            ('ceftolozane-tazobactam'),
            ('erythromycin'),
            ('amoxicillin-clavulanate susp.'),
            ('sulfameth/trimethoprim suspension'),
            ('dicloxacillin'),
            ('vancomycin antibiotic lock'),
            ('sulfameth/trimethoprim'),
            ('amikacin'),
            ('ampicillin'),
            ('gentamicin sulfate'),
            ('trimethoprim'),
            ('tetracycline hcl'),
            ('moxifloxacin'),
            ('sulfamethoxazole-trimethoprim'),
            ('sulfadiazine'),
            ('ceftazidime antibiotic lock'),
            ('penicillin v potassium'),
            ('penicillin g benzathine'),
            ('penicillin g potassium'),
            ('avelox'),
            ('rifampin'),
            ('tetracycline'),
            ('ery-tab'),
            ('erythromycin ethylsuccinate suspension'),
            ('ciprofloxacin'),
            ('doxycycline'),
            ('bactrim'),
            ('vancomycin '),
            ('amikacin inhalation'),
            ('penicillin g k graded challenge'),
            ('cefadroxil'),
            ('tobramycin inhalation soln'),
            ('vancocin'),
            ('cefepime graded challenge'),
            ('ceftolozane-tazobactam *nf*'),
            ('ceftazidime graded challenge'),
            ('piperacillin-tazo graded challenge'),
            ('augmentin suspension'),
            ('nitrofurantoin macrocrystal'),
            ('ampicillin-sulbact graded challenge'),
            ('clindamycin suspension'),
            ('ceftazidime-avibactam *nf*'),
            ('augmentin'),
            ('ampicillin graded challenge'),
            ('doxycycline hyclate  20mg'),
            ('clindamycin phosphate'),
            ('cefdinir'),
            ('gentamicin (bulk)'),
            ('streptomycin sulfate'),
            ('vancomycin intrathecal'),
            ('ceftazidime-avibactam (avycaz)'),
            ('nitrofurantoin '),
            ('cefpodoxime'),
            ('oxacillin'),
            ('cipro'),
            ('*nf* moxifloxacin'),
            ('flagyl'),
            ('nitrofurantoin'),
            ('levofloxacin graded challenge'),
            ('tobramycin with nebulizer'),
            ('keflex'),
            ('chloramphenicol na succ'),
            ('tobramycin in 0.225 % nacl'),
            ('ciprofloxacin '),
            ('doxycycline monohydrate'),
            ('vancomycin 125mg cap'),
            ('vancomycin ora'),
            ('gentamicin antibiotic lock'),
            ('cefotaxime'),
            ('ciproflox'),
            ('amoxicillin-clavulanate susp'),
            ('amoxicillin-pot clavulanate'),
            ('gentamicin intraventricular'),
            ('gentamicin 2.5 mg/ml in sodium citrate 4%'),
            ('sulfameth/trimethoprim '),
            ('trimethoprim-sulfamethoxazole'),
            ('cefuroxime axetil'),
            ('vancomycin 250 mg'),
            ('tobramycin'),
            ('levofloxacin 100mg/4ml solution'),
            ('macrodantin'),
            ('rifampin 150mg capsules'),
            ('cefoxitin'),
            ('*nf* cefoxitin sodium'),
            ('ampicillin-sulbactam sodium'),
            ('doxycycline '),
            ('bactrim '),
            ('bactrim ds'),
            ('neo*iv*gentamicin'),
            ('neo*iv*oxacillin'),
            ('neo*iv*vancomycin'),
            ('neo*iv*penicillin g potassium'),
            ('neo*iv*cefotaxime'),
            ('trimethoprim oral soln'),
            ('cephalexin suspension'),
            ('penicillin '),
            ('neo*iv*cefazolin'),
            ('levofloxacin '),
            ('neo*iv*ceftazidime'),
            ('neo*po*azithromycin'),
            ('erythromycin ethylsuccinate'),
            ('zithromax z-pak'),
            ('vancomycin for inhalation'),
            ('vancomycin for nasal inhalation'),
            ('penicillin v potassium suspension'),
            ('vancocin (vancomycin)'),
            ('minocycline 100mg tablets'),
            ('clindamycin  cap'),
            ('cefpodoxime 200mg tab'),
            ('clindamycin hcl caps'),
            ('clindamycin hcl'),
            ('nitrofurantoin monohyd/m-cryst'),
            ('nitrofurantoin macrocrystals'),
            ('nitrofurantoin macrocystals'),
            ('vancomycin capsule'),
            ('*nf* cefuroxime'),
            ('vancomycin oral capsule'),
            ('vancomycin caps'),
            ('erythromycin '),
            ('azithromycin po susp'),
            ('cayston'),
            ('vancomycin 250mg'),
            ('cefotaxime '),
            ('vancomycin-heparin lock'),
            ('amoxicillin-clavulanate po susp 400 mg-57 mg/5 ml'),
            ('penicillin v potassium solution'),
            ('inv-tivantinib'),
            ('cefazolin 2 g')
    ) as t(drug_name)
),

-- Filter prescriptions to antibiotics, excluding certain routes
filtered as (
    select
        p.subject_id,
        p.hadm_id,
        p.charttime,
        p.drug
    from prescriptions p
    inner join antibiotic_drugs a
        on p.drug = a.drug_name
    where 
        -- Exclude routes via eye, ear, or topical
        p.route is null
        or (
            p.route not like '%ear%'
            and p.route not like '%eye%'
            and p.route not in ('ou', 'os', 'od', 'au', 'as', 'ad', 'tp')
        )
)

select distinct
    subject_id,
    hadm_id,
    charttime,
    drug
from filtered
