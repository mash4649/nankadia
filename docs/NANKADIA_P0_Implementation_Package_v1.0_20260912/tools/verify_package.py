#!/usr/bin/env python3
from pathlib import Path
import json, re, sys, subprocess, shutil
from jsonschema.validators import Draft202012Validator

ROOT=Path(__file__).resolve().parents[1]
required=[
 '00_README.md','01_AUTHORITY_AND_TRACEABILITY.md','02_SLICE_A_IMPLEMENTATION_SOT_v2.0.md',
 '03_CONTEXT_AND_RECOMMENDATION_POLICY.md','04_EVENT_AND_MEASUREMENT_CONTRACT.md',
 '05_PROOF_COHORT_RUNBOOK.md','06_SEED_CORE_MIGRATION_CONTRACT.md','07_CALIBRATION_RUNBOOK.md',
 '08_SECURITY_RELIABILITY_GUARDRAILS.md','09_DEFERRED_AND_PROVISIONAL_REGISTER.md',
 '10_IMPLEMENTATION_TICKET_MAP.md','11_TECHNOLOGY_AND_BOUNDARY_BINDING.md','12_API_COMMAND_CONTRACT.md',
 'database/0001_schema.sql','database/0002_policy_helpers.sql','contracts/domain.ts','contracts/events.ts',
 'contracts/api.ts','contracts/policy.ts','ops/calibration_dashboard.sql','tests/acceptance_matrix.md',
 'seed/core_candidate_review_v241.csv','schemas/context-snapshot.schema.json','schemas/event-envelope.schema.json',
 'schemas/recommendation-decision.schema.json','schemas/seed-resolution.schema.json'
]
errors=[]
for rel in required:
    if not (ROOT/rel).exists(): errors.append(f'missing: {rel}')

for p in (ROOT/'schemas').glob('*.json'):
    try:
        obj=json.loads(p.read_text(encoding='utf-8'))
        Draft202012Validator.check_schema(obj)
    except Exception as e: errors.append(f'invalid schema {p.name}: {e}')
for p in (ROOT/'seed').glob('*.json'):
    try: json.loads(p.read_text(encoding='utf-8'))
    except Exception as e: errors.append(f'invalid JSON {p.name}: {e}')

# machine contracts must not contain deferred runtime concepts
machine_dirs=[ROOT/'database',ROOT/'contracts',ROOT/'schemas']
for d in machine_dirs:
    for p in d.rglob('*'):
        if p.is_file():
            txt=p.read_text(encoding='utf-8',errors='ignore').lower()
            for tok in ['system_skip_repair','system_relaxation','per_fact_ttl']:
                if tok in txt: errors.append(f'deferred runtime token {tok} in {p.relative_to(ROOT)}')

# event registry must not define forbidden system/deferred events
et=(ROOT/'contracts/events.ts').read_text(encoding='utf-8').lower()
for tok in ['skip_repair_applied','system_relaxation_applied','per_fact_ttl_expired']:
    if tok in et: errors.append(f'forbidden event: {tok}')

# the only kernel enums should contain the expected closed values
ctx=(ROOT/'contracts/domain.ts').read_text(encoding='utf-8')
for value in ['RETURNING_HOME','EN_ROUTE_FIXED','STAYING','WAITING','OPEN_ENDED','UNKNOWN','MEAL_PENDING','REST_NEEDED']:
    if value not in ctx: errors.append(f'missing domain enum value: {value}')

# Review CSV must have 36 core-candidate rows + header
csv_lines=(ROOT/'seed/core_candidate_review_v241.csv').read_text(encoding='utf-8-sig').splitlines()
if len(csv_lines)!=37: errors.append(f'expected 36 seed review rows, got {len(csv_lines)-1}')

# TypeScript strict compile if tsc exists
if shutil.which('tsc'):
    cfg=ROOT/'tools/tsconfig.verify.json'
    cfg.write_text(json.dumps({'compilerOptions':{'strict':True,'noEmit':True,'target':'ES2022','module':'ESNext','moduleResolution':'Bundler'},'include':[str(ROOT/'contracts/*.ts')]}),encoding='utf-8')
    r=subprocess.run(['tsc','-p',str(cfg)],capture_output=True,text=True)
    if r.returncode: errors.append('tsc failed:\n'+r.stdout+r.stderr)

if errors:
    print('PACKAGE VERIFY: FAIL')
    for e in errors: print('-',e)
    sys.exit(1)
print('PACKAGE VERIFY: PASS')
print('Note: PostgreSQL execution/RLS smoke tests require implementation runtime and are not performed by this verifier.')
