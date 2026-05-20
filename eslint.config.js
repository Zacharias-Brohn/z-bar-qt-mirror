export default [
    {
        ignores: ["scripts/fzf.js", "scripts/fuzzysort.js"],
    },
    {
        files: ["**/*.{js,jsx,ts,tsx,mjs,cjs}"],
        languageOptions: {
            ecmaVersion: 2021,
            sourceType: "module",
        },
        linterOptions: {
            reportUnusedDisableDirectives: true,
        },
        rules: {},
    },
];
