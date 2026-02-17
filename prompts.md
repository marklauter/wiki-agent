read https://code.claude.com/docs/en/best-practices.md https://code.claude.com/docs/en/features-overview.md
  @.claude/guidance/use-case-implementation-principles.md @use-cases/meta/PHILOSOPHY.md @use-cases/meta/TEMPLATE.md
   @use-cases/meta/USE-CASE-MODEL-ARTIFACTS.md @use-cases/ACTOR-CATALOG.md @use-cases/GLOSSARY.md
  @use-cases/SHARED-INVARIANTS.md @use-cases/USE-CASE-CATALOG.md all the files under @use-cases/domains\ and
  @use-cases/UC-05-provision-workspace.md . plan the fresh implementation of UC-05. you can use previous
  implementation artifacts located within @v0\ folder as reference for structural concepts, but all new artifacts
  will be created from scratch. ask the user for critical decisions.

 Verification

 Script-level testing

 1. parse-clone-url.sh: Test with HTTPS URL, SSH URL, URL without .git, invalid URL
 2. validate-github-repo.sh: Test with a real public repo and a nonexistent repo
 3. validate-github-wiki.sh: Test with a repo that has a wiki and one that doesn't
 4. provision-workspace.sh: Full happy-path test with a real repo. Then test cleanup: corrupt the wiki URL to force
 clone failure, verify source clone is cleaned up
 5. resolve-workspace.sh: After provisioning, verify it finds the workspace. Test with identifier, without, with
 nonexistent identifier

 End-to-end: run /up

 1. Start a fresh session
 2. Run /up
 3. Provide a real repo URL (e.g., a test repo you control)
 4. Verify: both repos cloned, config written, summary displayed
 5. Run /up again with same repo — verify it detects existing workspace
 6. Verify resolve-workspace.sh finds the workspace

 Hook testing

 1. After provisioning, attempt to write a file in the source clone — verify it's blocked
 2. Attempt to write a file in the wiki clone — verify it's allowed
 3. Attempt to write a file outside workspace/ — verify it's allowed

 Failure path testing

 1. Bad URL — verify parse error and retry prompt
 2. Nonexistent repo — verify clean stop after validation
 3. Missing wiki — verify wait-and-retry flow with instructions