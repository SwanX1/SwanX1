## AI changelog generator
A NodeJS script that turns Git logs into user-friendly changelogs.

#### How to use:

Provide an OpenAI API key with the environment variable `OPENAI_API_KEY`, and any custom prompt with `AI_CHANGELOG_CUSTOM`.

`AI_CHANGELOG_CUSTOM` examples:
  - `"Minecraft mod projects"`
  - `"a website"`

Run using `node path/to/script.js` inside the Git-tracked project directory.
