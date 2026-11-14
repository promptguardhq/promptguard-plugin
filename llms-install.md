# Installing PromptGuard's MCP server (for Cline and other agents)

PromptGuard's MCP server is hosted, so there is nothing to clone, build or
install. Add one remote server entry and let the user sign in.

1. Open the MCP settings file (`cline_mcp_settings.json`; in Cline: MCP
   Servers, then Configure). Read it first and keep every other server as it is.
2. Add this entry under `mcpServers`. If an entry named `promptguard` already
   points at the same URL, stop: it is installed.

   ```json
   {
     "mcpServers": {
       "promptguard": {
         "type": "streamableHttp",
         "url": "https://api.promptguard.co/mcp"
       }
     }
   }
   ```

3. No API key or header is needed. The server signs the user in to their
   PromptGuard account over OAuth the first time a tool needs it. Pause for the
   user to finish that sign-in in their browser; never ask them to paste a
   password or key into the chat.
4. Check it works: call `promptguard_scan_code` with the code
   `from openai import OpenAI\nclient = OpenAI()`. It needs no sign-in and
   should report the OpenAI import and client.

The user needs a PromptGuard account (free sign-up at
[promptguard.co](https://promptguard.co)) for every tool except
`promptguard_scan_code`. The tools are listed in this repository's README,
under "MCP tools".
