# Legacy Environment Preservation and Home-Pilot Packet

Date: 2026-07-29

The packet at `validation/home_pilot_packet/` preserves the frozen production
decision: Katya's existing WSL2 Ubuntu 22.04, Python 3.7, NumPy 1.18.3
environment is the study target. Modernization and multi-environment
equivalence are out of scope.

No production source changed. The packet:

- exports WSL only through a separate explicit Windows command;
- freezes environment, dependency, classifier, and `sitecustomize.py` custody
  without changing Conda;
- clones five detached locked worktrees and uses `PYTHONPATH`, not installation;
- runs the real provenance chain, targeted suites, and seven contracts;
- runs a bounded real-interface synthetic pipeline;
- inventories mounted OneDrive recordings read-only;
- gates the only real-data script behind explicit recording/config/classifier/
  PCA inputs and a confirmation token;
- stops before model fitting;
- packages bounded evidence with per-file SHA-256 records and excludes raw
  recording bytes by default.

The attached Fable audit is preserved verbatim with SHA-256
`4e7afc05238a4d3ba378e2c77dc8a11ec58eba1fcea858b90b715218e37c3d4d`.

Static validation details and unresolved home-only discoveries are inside the
packet. All four pull requests remain draft and unmerged.
