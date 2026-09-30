# Documentation

Suggested reading order for newcomers (humans and AI agents):

1. [design/architecture.md](design/architecture.md): layers, directory map, data flow
2. [design/module-conventions.md](design/module-conventions.md): where code goes, how modules look
3. [runbook/README.md](runbook/README.md): how to operate it day to day
4. [adr/](adr/): why it's shaped this way

| Section | What | When to update |
|---------|------|----------------|
| [adr/](adr/) | Architecture Decision Records | a structural decision is made or reversed |
| [design/](design/) | How things work now: architecture, conventions, secrets, hosts, desktop | the "how" changes |
| [plans/](plans/) | Multi-step efforts + [progress log](plans/progress.md) | during an effort |
| [runbook/](runbook/) | Step-by-step procedures | a procedure changes, or you did something by hand twice |

Keep docs next to the change: a PR that changes how something works updates
the design doc and runbook in the same commit.
