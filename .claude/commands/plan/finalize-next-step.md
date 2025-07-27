We just finished to implement the next project iteration.
We now need to verify the changes and commit them to git if all seems OK.

1. Read the following specs to get the general project context
- Read @aidocs/ProjectRadar-HighLevelArchitecture.md
- Read @aidocs/ProjectRadar-HighLevelRoadmap.md
- Read @aidocs/ProjectRadar-ProjectDescription.md
- Read @aidocs/implementation-plan/implementation-history.md

2. Read the description of the task that was just implemented.
- Read @aidocs/implementation-plan/next-step.md

3. Find all uncomitted code changes using git

4. Review the git diff and verify that the changes logically implement the steps outlined in @aidocs/implementation-plan/next-step.md

5. Run all unit tests and ensure that they pass

6. Update @aidocs/implementation-plan/implementation-history.md. Add a section for this iteration. Add all major changes.

7. Update @aidocs/implementation-plan/next-implementation-phase.md

8. Update the documentation in @claude.md and @Readme.md only if required

9. Update @aidocs/ProjectRadar-HighLevelArchitecture.md, @aidocs/ProjectRadar-HighLevelRoadmap.md and @aidocs/ProjectRadar-ProjectDescription.md only if there are discrepancies.

10. make sure that cwd is in the project root: ~/src/xrai/xrai.projectradar. Then add all changes to git (git add .)

11. commit and push all changes to the current branch using a multiline commit message that summarizes the changes.

12. Create a pull request to merge the new branch to main.

13. Only if successful: checkout the main branch and fetch all changes
