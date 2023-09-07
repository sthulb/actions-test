const { PR_NUMBER, PR_TITLE } = require("./constants")

module.exports = async ({github, context, core}) => {
    const FEAT_REGEX = /feat(\((.+)\))?(:.+)/
    const BUG_REGEX = /(fix|bug)(\((.+)\))?(:.+)/
    const DOCS_REGEX = /(docs|doc)(\((.+)\))?(:.+)/
    const CHORE_REGEX = /(chore)(\((.+)\))?(:.+)/
    const DEPRECATED_REGEX = /(deprecated)(\((.+)\))?(:.+)/
    const REFACTOR_REGEX = /(refactor)(\((.+)\))?(:.+)/

    const labels = {
        "feature": FEAT_REGEX,
        "bug": BUG_REGEX,
        "documentation": DOCS_REGEX,
        "internal": CHORE_REGEX,
        "enhancement": REFACTOR_REGEX,
        "deprecated": DEPRECATED_REGEX,
    }

    // Maintenance: We should keep track of modified PRs in case their titles change
    let miss = 0;
    
    // get PR labels from env
    const prLabels = process.env.PR_LABELS.split(",");
    const labelKeys = Object.keys(labels);

    core.info(`Labels on PR: ${prLabels}`);
    
    try {
        for (const label in labels) {
            const matcher = new RegExp(labels[label])
            const matches = matcher.exec(PR_TITLE)
            if (matches != null) {
                core.info(`Auto-labeling PR ${PR_NUMBER} with ${label}`)

                for (const prLabel in prLabels) {
                    core.info(`evaluating label: ${prLabel}`)
                    if (labelKeys.includes(prLabel)) {
                        core.info(`${prLabel} is a reserved label, we should remove it.`);
                        await github.rest.issues.removeLabel({
                            issue_number: PR_NUMBER,
                            owner: context.repo.owner,
                            repo: context.repo.repo,
                            name: prLabel
                        })
                    }
                }
                
                await github.rest.issues.addLabels({
                    issue_number: PR_NUMBER,
                    owner: context.repo.owner,
                    repo: context.repo.repo,
                    labels: [label]
                })

                return;
            } else {
                core.debug(`'${PR_TITLE}' didn't match '${label}' semantic.`)
                miss += 1
            }
        }
    } finally {
        if (miss == Object.keys(labels).length) {
            core.notice(`PR ${PR_NUMBER} title '${PR_TITLE}' doesn't follow semantic titles; skipping...`)
        }
    }
}
