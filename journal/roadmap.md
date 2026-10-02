# Roadmap

What comes next, in order. Each step points to backlog items and does not restate them. What was done is in `workbench-changelog.md` at the root. Move a step there when its workbench tag is cut.

1. **Testing philosophy** (grill): the ratio between testing everything and relying on user feedback; what is automated, logic vs UI. → `backlog-batch.md` → Open decisions.
2. **Gated import**: Synfactu's method 4.1.0 into `spec-gated-workflow/`, with MD-006 applied, then tag `spec-gated-workflow-v4.0.0` and freeze. → `backlog-gated.md` → Import.
3. **Fork batch**: create `batch-design-workflow/` from that tag. → `backlog-batch.md` → Fork.
4. **Shared fixes in batch**: the orchestrator skill, the MD-002 decision model, the cloud setup script, then the rest. → `backlog-batch.md` → Shared.
5. **Cycle machinery**: driver script, gates, cloud branches, migration check, traceability, prod release gate. → `backlog-batch.md` → Cycles.
6. **Bring batch to Synfactu**. → `backlog-batch.md` → Cycles.

Workbench tooling (`install.sh`, drift check) is done alongside, when a step needs it. → `backlog-batch.md` → Workbench.
