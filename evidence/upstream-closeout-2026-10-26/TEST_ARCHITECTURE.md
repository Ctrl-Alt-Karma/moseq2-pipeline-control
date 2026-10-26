# Upstream testing ownership at closeout

Source identities are bound in REACQUIRED_REPOSITORIES.json. App PR #291 merged
into release at `eefa3d5c15e21adef6e9ede343f2705f37d3e47b` on 2026-10-26.
Its description reports 306 notebook-walkthrough tests and Python 3.10+ pip/PyPI
packaging. This operation inspected the source, not the complete runtime suite.

The strict-xfail inventory expands parametrizations into 20 cases. Each row
contains nodeid, path/line, exact reason, docstring, exercised call names and
project-overlap classification. There are 18 decorators because one expands
into three cases. Three cases match our prior findings; two MP4-faststart cases
are related but distinct; fifteen have no project overlap. Only matching app
defects are promoted to hard passes in relevant branches. No unrelated xfail
backlog is adopted or repaired.

The current `moseq2-test` CONTRIBUTING.md assigns scientific/unit tests to their
package repositories and orchestration, locks, fixtures, shared comparison rules
and cross-package profiles to the central framework. Its current README defines
a Python 3.12 controller with an isolated Python 3.7 legacy worker; install-smoke
47 checks, historical-regression 264 outcomes, pipeline-smoke 28 steps, and an
unavailable future pipeline-end-to-end profile. It does not provide an already
qualified modern 1.4 cross-package instrument or permission to edit legacy locks.

Model PR #100 (`2ab129463a123ac53fb7cba362d25712ad2d227d`) and extract PR #176
(`20c80cc49e8468a0c2e717b5855817df03f0b2c8`) remain informational integration
pilots, not merged scientific changes. The focused contribution regressions here
live in the package repos under their existing test trees and are independently
runnable without notebook real-data fixtures. Installed wheel qualification
follows the central framework's no-editable-import principle without pretending
that its frozen legacy profiles certify modern source.

No central framework, worker image, golden output, source lock or known-failure
allowlist was changed. No unexpected behavior was added to an xfail/allowlist to
make these candidate tests green.
