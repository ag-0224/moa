---
applyTo: "openapi.yaml, mock-data.json, schema.sql, backend/src/**, frontend/lib/**"
---
# MOA API Contract Modification Instructions

When modifying API paths, DTO fields, or DB schemas:
1. Update `openapi.yaml` first.
2. Synchronize Spring Boot DTOs and Flutter API Services.
3. Update `mock-data.json` and unit tests.
