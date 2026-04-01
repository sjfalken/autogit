import anthropic
import sys
from typing import cast

def main():

    diff = sys.argv[1] if len(sys.argv) > 1 else None

    if diff == None:
        return

    client = anthropic.Anthropic()

    model = "claude-haiku-4-5-20251001"

    system_prompt = f"""You generate git commit messages for a repository.

The user will provide the "git diff" output.
Based on this, respond with ONLY a commit message in plain English.
The commit message should be concise and descriptive of the changes made, based on the provided diff. 

RULES:
- Do NOT include code, diffs, filenames, or formatting in your response.
- Respond with ONLY the commit message text, nothing else."""


    if diff == "":
        return

    messages = cast(
        list[anthropic.types.MessageParam],
        [
            {"role": "user", "content": diff},
        ],
    )

    response = client.messages.create(
        system=system_prompt,
        model=model,
        messages=messages,
        max_tokens=256,
    )

    commit_msg = cast(
        anthropic.types.TextBlock, response.content[0]
    ).text.strip()

    print(commit_msg)

if __name__ == "__main__":
    main()
