# # Mary — Local macOS Coding Brain

Mary is a lightweight local macOS assistant focused on helping Joe inspect, fix, and write Swift/Xcode code.

Mary is designed to run locally, use a local backend on `127.0.0.1:8082`, and help with developer workflows such as code review, file checking, terminal error diagnosis, and full replacement Swift files.

Mary does not rely on paid provider routing.

---

## Core rules

- Mary uses Brain-only decision logic.
- Mary should not fake provider/source routing.
- Mary should not hardcode template answers as her main coding system.
- Mary should inspect the request, understand the problem, and write the best code she can.
- Mary can use local terminal/project access when the app allows it.
- Mary should ask questions only when the request is genuinely unclear.
- When Joe asks for full replacement code, Mary should send the full file.

---

## Key features

- Local SwiftUI chat interface.
- Local backend health check at `http://127.0.0.1:8082/health`.
- Local completion endpoint at `http://127.0.0.1:8082/completion`.
- Brain rules through `MaryBrain`.
- Prompt building through `PromptBuilder`.
- Message memory through `MemoryManager`.
- File attachment support.
- Copyable chat messages.
- Code and error diagnosis workflow.

---

## Project structure

- `ContentView.swift` — Main SwiftUI chat interface.
- `ChatViewModel.swift` — Handles chat state, sending, attachments, and Mary replies.
- `MaryBrain.swift` — Main rules for Mary.
- `MaryTaskBrain.swift` — Decides the task mode.
- `MaryUnderstandingEngine.swift` — Reads the message and marks what it appears to need.
- `MaryPlanningEngine.swift` — Builds a simple plan.
- `MaryReasoningEngine.swift` — Produces Brain-only reasoning notes.
- `MarySource.swift` — Brain-only source setting.
- `MarySourceDecisionEngine.swift` — Keeps Mary on Brain Only.
- `PromptBuilder.swift` — Builds the backend prompt from MaryBrain rules and the user message.
- `MaryLocalLLMService.swift` — Sends prompts to the local backend.
- `MemoryManager.swift` — Stores recent message memory.
- `MaryScreenshotOCRService.swift` — Reads text from selected screenshots/images.
- `MarySelfCheckEngine.swift` — Performs simple Brain self-checking.

---

## Backend

Mary expects a local backend running on:

```text
127.0.0.1:8082
