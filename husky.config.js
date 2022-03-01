module.exports = {
  hooks: {
    "pre-commit": "yarn pre-commit",
    "commit-msg": "commitlint -E HUSKY_GIT_PARAMS",
  },
};
