# VinR Local AI / Offline-First Integration — Principal Engineering Implementation Plan

> **Document status:** Implementation-ready architecture plan  
> **Target platforms:** Android + iOS  
> **Primary constraint:** Offline-first; private conversations never leave the device  
> **AI strategy:** One local LLM + multiple task-specific prompts/policies, not multiple downloaded models  
> **Target resource envelope:** ~500 MB model/app AI footprint target; ~1.5 GB peak working-memory ceiling for the AI subsystem  
> **Architecture baseline:** Existing Flutter feature-driven clean architecture, Riverpod 2.5, GoRouter 13.2, repositories, `LocalAIService`, `StorageService`, voice recorder/STT, Dio/remote capability, notifications  
> **Reference:** `Ralein/streak-keeper` for streak/motivation/card concepts

---

## 0. Executive Summary

VinR should not become "an app with an LLM bolted onto it." The goal is to make the local model a **shared intelligence layer** available to the entire application while keeping the existing feature architecture intact.

The implementation should therefore introduce an AI platform layer between the feature repositories/controllers and the local inference runtime:

```text
Flutter UI
   ↓
Riverpod feature controllers/providers
   ↓
Feature repositories / use cases
   ↓
AI orchestration layer
   ├── Context Builder
   ├── Prompt Registry
   ├── Memory/Personalization
   ├── Safety/Policy
   ├── Structured Output Validator
   ├── Tool/Capability Router
   └── AI Task Scheduler
   ↓
Local AI Runtime
   ↓
One quantized local LLM
   ↓
Device CPU/GPU/NN acceleration where supported
```

The key architectural decision is:

> **One model, many behaviors.**

Do not download separate models for motivation, journaling, planning, chat, Glints, etc. Those behaviors should be implemented with prompt templates, structured output schemas, context selection, decoding parameters, and lightweight deterministic logic around the same model.

VinR should also follow a strict **local-first execution policy**:

1. User action enters the AI orchestration layer.
2. Relevant local context is assembled.
3. Local model runs on-device.
4. Result is validated.
5. Result is persisted locally if appropriate.
6. UI updates reactively.
7. Network is never required for core AI behavior.
8. Conversation content is never uploaded.

Remote AI, if retained at all, must be treated as a separate, explicitly opt-in capability and must never be the silent fallback for private conversations.

---

# 1. Product Goals

## 1.1 Core goals

The completed integration must provide:

- Local conversational AI.
- Personalized support.
- Context-aware responses.
- Offline operation.
- Glint generation.
- Motivational quote/card generation.
- Goal and habit support.
- Journaling assistance.
- Planning assistance.
- Reflection/summarization.
- Voice input.
- Voice output where the existing product design requires it.
- Consistent personality across the app.
- Local memory/personalization.
- Privacy-first storage.
- Android support.
- iOS support.
- Stable performance on ordinary mobile hardware.
- Graceful degradation when the model is unavailable.
- No UI freezes caused by inference.
- No uncontrolled memory growth.

## 1.2 Non-goals

Do **not**:

- Introduce multiple large downloaded LLMs.
- Run inference on the Flutter UI isolate.
- Store an unbounded chat transcript in RAM.
- send conversations to a remote service automatically.
- make every screen directly depend on the model.
- regenerate expensive AI content unnecessarily.
- make the model responsible for deterministic application logic.
- replace repositories with AI-specific state everywhere.
- put prompt strings directly inside widgets.
- allow arbitrary model output to mutate application data without validation.

---

# 2. Existing Architecture — Preserve and Extend

The known VinR baseline is already suitable for this integration:

```text
features/
core/
services/
repositories/
Riverpod providers
GoRouter
StorageService
LocalAIService
voice recorder / STT
Dio / remote capability
notifications
```

Do not perform a wholesale rewrite.

The integration should be an **additive architectural enhancement**.

The existing `LocalAIService` should become an implementation detail behind a stable AI abstraction rather than being called directly from individual features.

Recommended conceptual dependency direction:

```text
Feature UI
   ↓
Feature Controller / Notifier
   ↓
Use Case
   ↓
Repository
   ↓
AI Orchestrator
   ↓
AI Runtime
```

The UI must never know:

- model name,
- model file path,
- tokenizer details,
- quantization,
- inference backend,
- native FFI implementation,
- thread count,
- prompt formatting,
- context-window management.

---

# 3. Proposed AI Platform Layer

Create an AI platform module under the existing `core` architecture.

Suggested structure:

```text
lib/
  core/
    ai/
      domain/
        ai_task.dart
        ai_request.dart
        ai_response.dart
        ai_error.dart
        ai_capability.dart
        ai_message.dart
        ai_context.dart
        ai_memory.dart

      application/
        ai_orchestrator.dart
        context_builder.dart
        prompt_engine.dart
        memory_service.dart
        response_validator.dart
        ai_scheduler.dart
        ai_policy.dart
        ai_task_router.dart

      infrastructure/
        runtime/
          local_llm_runtime.dart
          local_llm_runtime_factory.dart
          model_manager.dart
          model_metadata.dart
          inference_config.dart

        prompting/
          prompt_registry.dart
          prompt_templates.dart

        storage/
          ai_database.dart
          conversation_store.dart
          memory_store.dart
          generation_cache.dart

        voice/
          speech_to_text_service.dart
          text_to_speech_service.dart
          voice_session_controller.dart

      presentation/
        providers/
          ai_providers.dart
          conversation_providers.dart
          voice_providers.dart
          glint_ai_providers.dart
```

Exact filenames may be adapted to the existing VinR naming conventions.

---

# 4. AI Domain Model

## 4.1 `AiTask`

Use an enum/sealed abstraction rather than arbitrary strings.

Example task families:

```text
conversation
glint_generation
glint_quote
glint_reflection
daily_checkin
goal_support
habit_support
journal_assist
planning
summarization
rewrite
suggestion
voice_response
```

This gives the orchestrator a predictable routing mechanism.

## 4.2 `AiRequest`

A request should contain:

```text
task
user_input
conversation_id?
context
personalization
constraints
response_schema
temperature/profile
max_output_tokens
priority
allow_memory_write
```

## 4.3 `AiResponse`

Return:

```text
text
structured_data?
task
generation_id
latency
token_count?
finish_reason
memory_updates?
warnings
```

The UI should not depend on raw runtime-specific response objects.

---

# 5. One Local Model Strategy

## 5.1 Model policy

Use one compact, mobile-capable instruct model.

The model selection must be based on actual mobile benchmarks, not desktop benchmark performance.

Required characteristics:

- quantized weights,
- mobile-compatible runtime,
- reasonable context window,
- instruction-following capability,
- multilingual robustness if VinR needs it,
- stable generation at low memory,
- Android support,
- iOS support,
- CPU fallback,
- hardware acceleration where available.

The initial target is approximately:

```text
Model/package target: ~500 MB class
Peak AI working memory target: ≤ 1.5 GB
```

These are **engineering budgets**, not permission to consume the full limit.

The preferred runtime should maintain a substantially lower steady-state footprint.

## 5.2 Quantization

Start with a mobile-friendly quantized model.

Benchmark at least:

- model load time,
- first-token latency,
- tokens/sec,
- peak RSS,
- sustained memory,
- battery impact,
- thermal behavior,
- context scaling.

Do not select a model solely because its file size is below 500 MB.

A model that technically fits but causes:

- 1.5 GB+ spikes,
- severe thermal throttling,
- UI jank,
- process termination,

is not acceptable.

## 5.3 Model lifecycle

The model must **not** load during application startup.

Correct:

```text
App launch
   ↓
UI becomes usable
   ↓
AI capability initialization in background
   ↓
Model downloaded/verified if needed
   ↓
Model loaded lazily on first AI request
   ↓
Runtime kept warm according to policy
```

Possible runtime states:

```text
uninitialized
checking
downloading
verifying
loading
ready
busy
cooling_down
unloading
error
```

---

# 6. Model Manager

Create a `ModelManager`.

Responsibilities:

- determine whether the model exists,
- verify model integrity,
- expose model version,
- download/install model when needed,
- support resumable installation if the transport permits,
- prevent duplicate downloads,
- prevent simultaneous model initialization,
- report progress,
- manage model lifecycle,
- unload when memory pressure requires it,
- migrate model versions safely.

Never let a feature directly manipulate the model file.

## 6.1 Integrity

Maintain metadata:

```text
modelId
version
format
quantization
size
sha256
runtimeCompatibility
minimumOS
```

Before loading:

```text
exists
→ size valid
→ checksum valid
→ metadata compatible
→ runtime supported
→ load
```

If validation fails, mark the model unusable and provide a repair path.

---

# 7. Inference Runtime Abstraction

Create:

```dart
abstract class LocalLlmRuntime {
  Future<void> initialize(ModelMetadata model);
  Future<void> dispose();

  Stream<AiToken> generate(AiGenerationRequest request);

  Future<bool> isReady();
  Future<AiRuntimeStats> stats();
}
```

The rest of VinR must depend only on this abstraction.

Possible implementation:

```text
LocalLlmRuntime
   └── NativeLocalLlmRuntime
        └── FFI / platform bridge
             ├── Android native runtime
             └── iOS native runtime
```

The exact inference library should be selected during Phase 2 after benchmarking candidate mobile runtimes.

Do not couple the domain layer to a specific native library.

---

# 8. Threading and UI Stability

This is one of the most important requirements.

## 8.1 Never block the UI isolate

Inference must run outside the Flutter UI execution path.

Use:

```text
Flutter UI isolate
      │
      ├── state updates
      ├── streaming tokens
      └── user interaction
              │
              ▼
        native/background runtime
              │
              ▼
          local model
```

The model must never perform a long synchronous operation on the UI isolate.

## 8.2 Backpressure

Do not allow ten simultaneous generations because ten widgets requested AI.

The scheduler should enforce:

```text
Interactive request → highest priority
Voice request       → high priority
Glint generation    → medium/low priority
Background summary  → low priority
```

Only one heavy generation should normally execute at a time unless profiling proves concurrent inference is safe.

## 8.3 Cancellation

Every generation should support cancellation.

Examples:

- user leaves chat,
- user starts a new prompt,
- user presses stop,
- voice session ends,
- app enters memory pressure.

Cancellation must actually interrupt generation rather than merely ignoring the final result.

---

# 9. AI Task Scheduler

Implement a central scheduler.

Concept:

```text
AiScheduler
  ├── interactive queue
  ├── voice queue
  ├── background queue
  └── maintenance queue
```

Rules:

1. Interactive requests preempt queued background work.
2. Only one expensive background generation runs at a time.
3. Glint pre-generation must never compete with an active conversation.
4. Model loading happens once.
5. Duplicate identical requests should be coalesced/cached.
6. Cancel stale requests.

This is critical for preventing VinR from feeling slow.

---

# 10. Prompt Architecture

The application uses **one model with many prompts**.

Create a central `PromptRegistry`.

Example:

```text
PromptRegistry
  ├── conversationPrompt
  ├── glintPrompt
  ├── motivationalCardPrompt
  ├── dailyCheckinPrompt
  ├── journalPrompt
  ├── planningPrompt
  ├── reflectionPrompt
  ├── goalSupportPrompt
  └── voiceConversationPrompt
```

Prompts should not be duplicated across features.

---

# 11. Prompt Profiles

Each task receives a profile.

Example:

```text
Conversation:
  temperature: moderate
  concise: false

Glint:
  temperature: moderate
  concise: true
  structured output: required

Motivational card:
  temperature: slightly creative
  output length: very short

Journal reflection:
  temperature: low/moderate
  empathetic style
  no unsolicited diagnosis

Planner:
  temperature: low
  structured output
```

The model remains the same.

Only:

- system instructions,
- context,
- output schema,
- decoding settings,
- task policy

change.

---

# 12. Context Builder

The biggest difference between a generic local chatbot and a useful VinR assistant will be context quality.

Create:

```text
ContextBuilder
```

It should selectively assemble:

```text
current user message
+
current screen/task
+
relevant recent conversation
+
relevant personal preferences
+
relevant goals/habits
+
relevant Glint state
+
relevant recent activity
```

Do **not** dump the entire database into the prompt.

---

# 13. Context Budgeting

Context must be token-budgeted.

Example policy:

```text
System/personality: fixed
Task instructions: fixed
Current input: high priority
Recent conversation: medium/high priority
Relevant memory: selected
Old history: summarized
```

When the conversation grows:

```text
raw messages
     ↓
recent window + summary
     ↓
compact context
```

Never keep sending the complete historical conversation.

---

# 14. Local Memory

Personalization should be implemented as a controlled local memory layer.

Memory categories:

```text
preferences
goals
habits
communication_style
important_user_facts
successful_support_patterns
Glint preferences
```

Memory should be:

- local,
- inspectable,
- editable,
- deletable,
- bounded,
- selectively retrieved.

## 14.1 Do not store everything

The model must not automatically convert every sentence into memory.

Use:

```text
candidate memory
→ relevance check
→ policy check
→ confidence threshold
→ local persistence
```

Only durable information should become memory.

---

# 15. Conversation Storage

Conversation data remains on-device.

Recommended structure:

```text
Conversation
  id
  createdAt
  updatedAt
  title
  summary
  archived

Message
  id
  conversationId
  role
  content
  createdAt
  tokenEstimate
  metadata
```

Do not store model internal reasoning.

Store only the user-visible assistant response and required metadata.

---

# 16. Privacy Boundary

The privacy rule is:

> **Conversation data does not leave the device.**

The AI platform should make this difficult to violate accidentally.

Create explicit data classes:

```text
LocalPrivateData
RemoteSafeData
```

A private conversation must never be passed to Dio/remote APIs.

If a remote service exists for unrelated application functionality, the AI layer must not automatically forward private AI context to it.

Add an explicit privacy policy enforcement point:

```text
AiPolicy.canSendToNetwork(request)
```

For normal VinR conversation requests:

```text
false
```

---

# 17. Glint System

Glint should become a first-class AI task rather than a special case.

Recommended pipeline:

```text
User state
   ↓
Glint context builder
   ↓
Glint prompt
   ↓
Local LLM
   ↓
Structured Glint response
   ↓
Validator
   ↓
Glint repository
   ↓
Card renderer
```

---

# 18. Glint Card Generation

The requested Streak Keeper-style concept should be adapted rather than copied literally.

The reference repository demonstrates a compact motivational dashboard containing:

- streak information,
- recent activity,
- mood,
- a last quote,
- a streak grid,
- generated daily content. fileciteturn1file0L2-L2

For VinR, the equivalent should be **Glint cards**.

Possible card types:

```text
Motivation
Quote
Daily Focus
Streak
Reflection
Small Win
Reminder
Goal Progress
Mood
Challenge
Encouragement
```

---

# 19. Glint Structured Output

Do not ask the model for arbitrary UI markup.

Use a strict schema.

Example conceptual output:

```json
{
  "type": "motivation",
  "title": "Keep going",
  "body": "Small progress still counts.",
  "quote": "Consistency compounds.",
  "mood": "encouraging",
  "accent": "default",
  "priority": 3
}
```

The renderer decides the actual UI.

The model provides content, not layout code.

---

# 20. Glint Card Safety / Validation

Validate:

- card type,
- title length,
- body length,
- quote length,
- allowed metadata,
- missing fields,
- malformed JSON,
- inappropriate content,
- duplicate content.

If parsing fails:

```text
model output
   ↓
JSON parser
   ↓
schema validator
   ↓
repair prompt OR deterministic fallback
```

Never render malformed model output directly.

---

# 21. Motivational Quote Strategy

Use the model to create personalized motivational text, but avoid pretending generated text is a quote from a real person.

If a generated line is not sourced:

```text
"Consistency compounds."
— VinR
```

or simply:

```text
"Consistency compounds."
```

Do not attach a real person's name unless the quote is sourced from a verified local quote dataset.

This also keeps the offline system deterministic and avoids fabricated attribution.

---

# 22. Glint Generation Frequency

Do not regenerate cards on every app rebuild.

Use deterministic triggers:

```text
new day
new meaningful activity
goal milestone
streak change
manual refresh
scheduled Glint refresh
```

Cache generated cards.

Example:

```text
glint/{date}/{cardType}/{contextHash}
```

If the same context is encountered again, return the cached card.

---

# 23. Glint Personalization

Glint context should include only relevant information.

Example:

```text
User prefers concise encouragement.
Current goal: X.
Recent progress: Y.
Current streak: Z.
Recent mood/check-in: A.
Recent Glint shown: B.
```

This allows the same model to generate personalized content without a separate "motivation model."

---

# 24. Chat Experience

Chat should support:

```text
typing
streaming response
stop generation
retry
regenerate
copy
delete
conversation history
conversation title
local persistence
voice input
voice output
```

## 24.1 Streaming

Render tokens incrementally.

Do not write every token to persistent storage.

Instead:

```text
tokens → UI buffer
       ↓
periodic/coalesced UI updates
       ↓
final response
       ↓
single persistence write
```

This prevents excessive database writes and rebuilds.

---

# 25. Riverpod Integration

Expose AI state through Riverpod.

Suggested providers:

```text
aiRuntimeProvider
aiAvailabilityProvider
aiModelStateProvider
aiGenerationProvider
conversationRepositoryProvider
conversationProvider
messageStreamProvider
voiceSessionProvider
glintProvider
glintGenerationProvider
```

Use family providers for IDs where necessary.

Avoid a single global provider containing the entire application AI state.

---

# 26. State Model

Use explicit states:

```text
idle
initializing
generating
streaming
completed
cancelled
error
modelUnavailable
```

The UI should be able to render all states without knowing implementation details.

---

# 27. Voice — Current Broken Capability

Voice must be treated as a dedicated subsystem, not as a small button attached to chat.

Pipeline:

```text
Microphone
   ↓
Recorder
   ↓
Audio file / stream
   ↓
STT
   ↓
text
   ↓
AI orchestrator
   ↓
LLM
   ↓
TTS
   ↓
speaker
```

First priority is to make the existing voice path reliable.

---

# 28. Voice Diagnostic Phase

Before changing implementation, instrument every stage:

```text
permission granted?
recorder initialized?
recording started?
audio bytes produced?
audio format?
sample rate?
channel count?
STT initialized?
STT received audio?
transcription produced?
AI request started?
AI response received?
TTS initialized?
audio playback started?
```

Each stage should expose a structured error.

Avoid generic:

```text
Voice failed.
```

Prefer:

```text
VOICE_PERMISSION_DENIED
VOICE_RECORDER_INIT_FAILED
VOICE_EMPTY_AUDIO
VOICE_STT_TIMEOUT
VOICE_STT_UNAVAILABLE
VOICE_TTS_FAILED
```

---

# 29. Voice Offline Policy

The voice pipeline should be local-first too.

Do not assume the operating system's online speech service is available.

The final architecture should support a local STT/TTS path where practical and platform-native fallback only when it does not violate the product privacy contract.

The implementation must clearly distinguish:

```text
local transcription
platform transcription
remote transcription
```

If a platform API sends audio externally, it must not silently be presented as fully local.

---

# 30. Voice Performance

Voice should not hold the LLM model unnecessarily.

Pipeline optimization:

```text
record
→ transcribe
→ stop recorder
→ invoke LLM
→ speak response
```

If memory pressure is severe, voice and LLM runtime lifecycle should be coordinated.

---

# 31. Deterministic Logic vs LLM Logic

Use deterministic application code for:

- streak calculations,
- dates,
- reminders,
- notification scheduling,
- progress percentages,
- validation,
- navigation,
- permissions,
- persistence,
- sorting,
- filtering.

Use the LLM for:

- language,
- suggestions,
- explanations,
- reflection,
- motivation,
- natural conversation,
- personalized wording,
- card content.

Never ask the model to calculate critical application state if the application can calculate it exactly.

Example:

```text
BAD:
LLM decides user's streak = 17.

GOOD:
Repository calculates streak = 17.
LLM receives "current streak = 17" and writes an appropriate message.
```

---

# 32. Tool / Capability Layer

The LLM should not directly access repositories.

Create controlled capabilities:

```text
get_user_context
get_goals
get_habits
get_recent_activity
get_streak
create_glint
save_memory
create_reminder
```

Each capability must have:

- typed input,
- typed output,
- permission policy,
- validation,
- logging.

The model may request a capability; the orchestrator decides whether it is allowed.

---

# 33. No Autonomous Dangerous Actions

For actions with side effects:

```text
create reminder
delete data
change goal
modify habit
```

the model should produce an intent.

The application validates the intent.

For sensitive/destructive actions, require explicit user confirmation.

---

# 34. Prompt Injection Defense

Even though everything is local, untrusted user-generated content can still manipulate the model.

Treat:

- imported notes,
- journal content,
- external text,
- copied content,

as untrusted data.

System/task instructions must remain higher priority.

Do not concatenate raw content into privileged instructions without clear delimiters.

---

# 35. Safety Layer

Create a lightweight local `AiPolicy`.

Responsibilities:

- prevent unsafe assistant behavior,
- prevent fabricated claims,
- avoid overconfident high-stakes advice,
- prevent privacy leakage,
- prevent unauthorized tool actions,
- control memory writes.

For sensitive user situations, the assistant should provide appropriate supportive language and encourage professional help where warranted without pretending to be a clinician.

---

# 36. Generation Profiles

Use centralized profiles:

```text
FastChat
BalancedChat
DeepReflection
Glint
Motivational
Planner
Voice
```

Each profile controls:

```text
max tokens
temperature
top-p / equivalent
context budget
stop sequences
streaming
priority
```

This makes tuning one place rather than editing dozens of features.

---

# 37. Response Caching

Caching is essential for performance.

Cache only deterministic or low-volatility results.

Good cache candidates:

- Glint cards,
- motivational cards,
- repeated suggestions,
- summaries,
- generated titles.

Avoid caching highly dynamic conversational answers unless the request/context hash is identical.

Use:

```text
requestHash
modelVersion
promptVersion
contextVersion
response
createdAt
```

When prompt/model version changes, invalidate the relevant cache.

---

# 38. Prompt Versioning

Every prompt should have a version:

```text
glint.v1
chat.v1
planner.v1
```

Persist the prompt version with generated artifacts.

This makes debugging possible.

---

# 39. Observability

Measure without collecting private conversation contents.

Allowed local telemetry/debug metrics:

```text
model load time
generation latency
first token latency
tokens generated
generation cancellation
peak memory
runtime errors
voice stage failures
cache hit rate
```

Do not upload conversation text.

In debug builds, provide an internal AI diagnostics screen.

---

# 40. Performance Budgets

Define hard budgets before optimization.

Suggested initial targets:

| Metric | Target |
|---|---:|
| UI frame rate during generation | no sustained jank |
| UI thread blocking | ~0 ms from inference |
| Model initialization | asynchronous |
| Duplicate generation | prevented |
| Peak AI memory | ≤ 1.5 GB |
| Model package target | ~500 MB class |
| Conversation persistence | batched/coalesced |
| Glint regeneration | event-driven |
| Background AI | cancellable |
| App startup | model not loaded synchronously |

These are acceptance targets and should be validated on real devices.

---

# 41. Memory Management

Implement:

```text
ModelManager
+
AiScheduler
+
MemoryPressureMonitor
```

On memory pressure:

```text
cancel background generation
→ release temporary buffers
→ clear old token buffers
→ unload model if necessary
→ preserve conversation data
```

Do not rely on the OS to kill the process and hope the app recovers.

---

# 42. Model Warm / Cold Strategy

Use adaptive behavior.

After recent interaction:

```text
keep model warm
```

After inactivity:

```text
allow runtime to unload
```

Do not keep a large model resident forever on low-memory devices.

Possible policy:

```text
interactive session:
  warm

idle:
  warm for short grace period

background:
  unload

memory pressure:
  unload immediately
```

Tune based on device profiling.

---

# 43. Battery / Thermal Policy

Local inference is CPU/GPU intensive.

The scheduler should know whether the app is:

```text
foreground
background
battery constrained
thermally constrained
```

Never run large Glint generation repeatedly in the background.

Prefer:

```text
generate once
cache
reuse
```

over:

```text
generate every screen open
```

---

# 44. Offline-First Data Architecture

Core VinR functionality should work without a network connection.

Preferred flow:

```text
UI
 ↓
local repository
 ↓
local database/storage
```

Network synchronization, if used for non-AI application features, should be secondary:

```text
local write
 ↓
sync queue
 ↓
network when available
```

The AI subsystem does not depend on the sync layer.

---

# 45. Startup Sequence

Target startup:

```text
main()
 ↓
initialize Flutter
 ↓
initialize local storage
 ↓
initialize Riverpod
 ↓
render app
 ↓
initialize AI manager asynchronously
```

Do NOT:

```text
main()
 ↓
load 500 MB model
 ↓
initialize runtime
 ↓
render app
```

---

# 46. First AI Interaction

When user first opens AI:

```text
AI unavailable
      ↓
check model
      ↓
model exists?
  ├── yes → load
  └── no → installation UI
```

Show meaningful progress.

Do not show a frozen screen.

---

# 47. Model Installation UX

Provide:

```text
Download model
Download progress
Storage required
Current size
Verification
Ready
Retry
Delete model
```

The user should understand that the local model is a substantial on-device component.

---

# 48. Storage Management

The model should be separable from user data.

Conceptually:

```text
App data
  ├── database
  ├── conversations
  ├── Glints
  └── settings

AI assets
  └── model
```

Deleting the model must not delete conversations.

Deleting conversations must not delete the model.

---

# 49. Android Implementation

Android native layer should:

- host the local inference runtime,
- expose lifecycle-safe APIs,
- support cancellation,
- report memory/runtime errors,
- avoid main-thread inference,
- cooperate with Flutter lifecycle.

Validate on:

```text
low-memory Android
mid-range Android
modern Android
```

Do not optimize exclusively for the developer device.

---

# 50. iOS Implementation

iOS native layer should:

- use an appropriate native/mobile inference backend,
- avoid blocking the main thread,
- handle app backgrounding,
- handle memory warnings,
- cancel safely,
- release model resources when necessary.

Validate on:

```text
older supported iPhone
mid-range supported iPhone
recent iPhone
```

---

# 51. Platform Abstraction

Flutter code should expose one interface:

```text
LocalLlmRuntime
```

Platform differences remain below it.

```text
Flutter
  ↓
Dart abstraction
  ↓
platform bridge
  ├── Android runtime
  └── iOS runtime
```

Never put:

```dart
if (Platform.isAndroid) ...
```

throughout the feature layer.

Platform branching belongs in infrastructure.

---

# 52. Repository Integration

Feature repositories remain responsible for feature data.

Example:

```text
GlintRepository
ConversationRepository
MemoryRepository
GoalRepository
HabitRepository
```

AI orchestrator consumes repositories through controlled interfaces.

Do not make repositories depend on UI.

---

# 53. Example Glint Flow

```text
GlintScreen
    ↓
GlintController
    ↓
GlintUseCase
    ↓
GlintRepository
    ↓
GlintContextBuilder
    ↓
AiOrchestrator
    ↓
PromptRegistry["glint.v1"]
    ↓
LocalLlmRuntime
    ↓
Structured response
    ↓
GlintValidator
    ↓
GlintRepository
    ↓
Riverpod state update
    ↓
GlintCard widget
```

---

# 54. Example Conversation Flow

```text
Chat UI
 ↓
ChatController
 ↓
ConversationUseCase
 ↓
ContextBuilder
 ↓
Memory retrieval
 ↓
PromptRegistry
 ↓
AiScheduler
 ↓
LocalLlmRuntime
 ↓
stream tokens
 ↓
Chat UI
 ↓
final response
 ↓
ConversationRepository
```

---

# 55. Example Voice Flow

```text
Voice button
 ↓
VoiceSessionController
 ↓
permission
 ↓
recorder
 ↓
STT
 ↓
text
 ↓
ConversationUseCase
 ↓
AI
 ↓
response
 ↓
TTS
 ↓
speaker
```

Every stage emits state.

---

# 56. Error Taxonomy

Create typed errors.

```text
AiError
  ├── ModelMissing
  ├── ModelCorrupt
  ├── ModelLoadFailed
  ├── RuntimeUnavailable
  ├── GenerationFailed
  ├── GenerationCancelled
  ├── ContextTooLarge
  ├── InvalidStructuredOutput
  ├── MemoryPressure
  ├── PermissionDenied
  ├── VoiceUnavailable
  └── Unknown
```

Map them to human-readable UI messages separately.

---

# 57. Fallback Behavior

Every AI feature needs a non-LLM fallback.

Examples:

```text
Glint:
  deterministic motivational card

Chat:
  model unavailable message + recovery UI

Streak:
  deterministic streak card

Quote:
  bundled verified quote dataset

Voice:
  clear unavailable/error state
```

This makes the app resilient.

---

# 58. Deterministic Glint Fallback

Bundle a small set of motivational content.

Use:

```text
category
mood
goal
streak state
```

to select appropriate content.

This ensures Glint still works when:

- model is not downloaded,
- model failed,
- memory is constrained,
- generation is cancelled.

---

# 59. Testing Strategy

Testing must happen at four levels.

## 59.1 Unit tests

Test:

- prompt construction,
- context selection,
- token budgeting,
- memory rules,
- response parsing,
- schema validation,
- caching,
- scheduler priority,
- privacy policy,
- Glint fallback,
- voice state transitions.

## 59.2 Integration tests

Test:

```text
feature → repository → orchestrator → fake runtime
```

Use a fake LLM runtime.

Do not require the actual model for ordinary CI tests.

## 59.3 Runtime tests

Use a real small/target model on physical devices.

Test:

- loading,
- generation,
- cancellation,
- memory,
- thermal behavior,
- lifecycle.

## 59.4 End-to-end tests

Test:

```text
open app
→ create conversation
→ generate response
→ close app
→ reopen
→ conversation persists
```

and:

```text
activity
→ Glint generation
→ card persistence
→ reopen
→ same card restored
```

and:

```text
voice
→ record
→ transcribe
→ AI
→ playback
```

---

# 60. Performance Test Matrix

Create a repeatable benchmark harness.

For each device:

```text
cold model load
warm generation
first token
20-token generation
100-token generation
Glint generation
chat generation
voice pipeline
memory peak
battery impact
thermal behavior
```

Record:

```text
device
OS
model version
quantization
runtime version
prompt version
latency
memory
tokens/sec
```

---

# 61. AI Quality Evaluation

Create a fixed local evaluation set.

Categories:

```text
conversation
personalization
motivation
Glint
planning
reflection
summarization
voice-transcribed input
edge cases
safety
```

For each test:

```text
input
expected behavior
bad behavior
quality score
```

Do not optimize only for benchmark scores. Evaluate whether the output feels useful inside the actual VinR UX.

---

# 62. Glint Evaluation

Minimum checks:

- card is short,
- card is meaningful,
- no fabricated attribution,
- reflects actual user context,
- no repeated card spam,
- does not expose private information unnecessarily,
- valid schema,
- visually fits card limits.

---

# 63. Conversation Evaluation

Measure:

```text
relevance
personalization
consistency
conciseness
instruction following
context retention
hallucination rate
privacy compliance
```

---

# 64. Voice Evaluation

Measure separately:

```text
permission success
recording success
audio quality
STT accuracy
STT latency
AI latency
TTS latency
end-to-end latency
failure recovery
```

Do not debug voice as one monolithic feature.

---

# 65. Logging Rules

Debug logs may include:

```text
task
request ID
latency
model state
error type
token counts
```

Do NOT log:

```text
full conversation
journal content
private memories
raw microphone data
model prompt containing private context
```

Redact sensitive values.

---

# 66. Database Migration Strategy

Add AI tables/collections incrementally.

Suggested:

```text
conversations
messages
ai_memories
ai_generations
glints
ai_cache
```

Use schema migrations.

Do not change existing user data structures destructively.

---

# 67. Glint Data Model

Conceptual:

```text
Glint
  id
  userId/localOwner
  type
  title
  body
  quote
  mood
  createdAt
  source
  promptVersion
  modelVersion
  contextHash
  isRead
```

`source` could be:

```text
generated
fallback
user_created
```

---

# 68. Conversation Data Retention

Allow users to:

```text
delete one conversation
delete all conversations
clear memories
clear generated Glints
reset AI
delete downloaded model
```

"Reset AI" should have an explicit confirmation.

---

# 69. AI Settings

Provide settings for:

```text
AI enabled
local model status
model storage usage
voice
speech rate
personality/style
memory enabled
show generated Glints
clear conversations
clear AI memory
reset AI data
delete model
```

The exact UI should follow VinR's existing design system.

---

# 70. Personalized Support

Personalization should be subtle.

The assistant can use:

```text
user's goals
habits
preferred communication style
recent progress
previously successful patterns
```

But it should not constantly repeat personal facts.

Use relevance scoring.

Bad:

> "Because you told me three weeks ago that you like X..."

Good:

> "You're already making progress on this—let's keep the next step small."

---

# 71. Personalization Memory Hierarchy

Prioritize:

```text
current task
>
recent context
>
active goals
>
stable preferences
>
long-term memories
>
old conversation
```

This reduces prompt size and improves relevance.

---

# 72. Prompt Context Assembly Example

Conceptual:

```text
SYSTEM:
You are VinR...

TASK:
Help the user...

USER CONTEXT:
Active goal: ...
Current streak: ...

RECENT CONTEXT:
...

MEMORY:
Only relevant memories...

USER:
...
```

Keep sections clearly delimited.

---

# 73. Model Output Constraints

Where structured data is required, prefer constrained/validated output.

For example:

```text
Glint:
JSON only

Planner:
JSON only

Conversation:
natural text
```

Do not parse arbitrary prose using brittle regex when a schema is available.

---

# 74. Streaming Structured Output

For JSON-producing tasks, it may be preferable to buffer generation until the structure validates.

Do not expose half-valid JSON to the UI.

For normal conversation, stream immediately.

---

# 75. AI Dependency Injection

Inject:

```text
LocalLlmRuntime
PromptRegistry
ContextBuilder
MemoryRepository
ConversationRepository
AiPolicy
AiScheduler
```

This enables:

- testing,
- mock runtime,
- future model replacement,
- debugging.

---

# 76. Do Not Lock the Architecture to the First Model

Model metadata should be data-driven.

Avoid:

```dart
if (model == "X") ...
```

Prefer:

```text
ModelMetadata
RuntimeCapabilities
GenerationProfile
```

This allows a future model replacement without rewriting VinR.

---

# 77. Remote AI Handling

If the existing Dio/remote AI path is retained:

```text
RemoteAIService
```

must remain separate from:

```text
LocalLlmRuntime
```

The orchestrator may support:

```text
LocalOnly
```

as the default policy.

No automatic remote fallback for private conversation.

A future remote feature can be explicitly scoped and consented.

---

# 78. Network Independence Test

Disable all network access.

VinR must still be able to:

- open,
- load local data,
- open conversations,
- create supported local content,
- generate AI responses when model exists,
- create Glint cards,
- use local deterministic fallbacks.

This test should be part of release qualification.

---

# 79. App Lifecycle

Handle:

```text
foreground
background
inactive
memory warning
termination
resume
```

If generation is active when the app backgrounds:

```text
pause/cancel according to policy
```

Do not assume the runtime can continue safely in the background.

---

# 80. Crash Recovery

If native inference crashes:

```text
detect runtime failure
→ mark runtime unhealthy
→ release resources
→ recover/reinitialize
→ show fallback
```

Do not repeatedly restart the model in a tight loop.

Use bounded retries.

---

# 81. Corrupt Model Recovery

If model validation fails:

```text
mark corrupt
→ unload
→ remove broken asset
→ request reinstall
```

Never attempt to run a partially downloaded model.

---

# 82. Generation Watchdog

Each generation should have:

```text
start timestamp
deadline
cancellation token
```

If the runtime becomes unresponsive:

```text
watchdog
→ cancel
→ dispose/recover runtime
→ return controlled error
```

This prevents a hung native runtime from hanging the feature forever.

---

# 83. Concurrency Rules

At most:

```text
1 heavy local generation
```

by default.

Multiple lightweight deterministic operations can happen concurrently.

If future hardware benchmarking demonstrates safe concurrency, make it configurable rather than implicit.

---

# 84. Glint Background Generation

Do not generate Glints continuously.

Allowed triggers:

```text
new day
user completes meaningful action
user opens Glint after stale cache
manual refresh
scheduled local event if platform permits
```

Use a cooldown.

Example:

```text
minimum regeneration interval
+
context hash
+
daily generation budget
```

---

# 85. Battery-Aware Glint

If the user has not opened Glint, there is little reason to run expensive generation.

Prefer:

```text
generate when relevant
```

rather than:

```text
generate every midnight regardless of usage
```

---

# 86. Notifications

Notifications should use deterministic content where possible.

If AI-generated notification text is used:

- generate once,
- cache it,
- validate it,
- schedule locally,
- never invoke the model repeatedly per notification.

---

# 87. Security

Protect:

- model files,
- conversation database,
- memory database,
- local configuration.

Use platform-appropriate secure storage for secrets/settings that require it.

Do not put API keys in the local model package.

The local model itself should not require a network API key.

---

# 88. Model Download Security

If model assets are downloaded:

```text
HTTPS
→ authenticated/known source
→ checksum verification
→ atomic install
```

Download into a temporary file.

Only rename into the active model location after validation succeeds.

---

# 89. Atomic Model Installation

Use:

```text
model.tmp
 ↓
download
 ↓
verify
 ↓
model.ready
 ↓
atomic rename
```

Never overwrite a known-good model with an incomplete download.

---

# 90. Feature Adoption Order

Do not integrate AI into every screen simultaneously.

Recommended order:

```text
1. runtime
2. orchestrator
3. chat
4. memory
5. Glint
6. voice
7. other feature integrations
8. background optimization
```

This minimizes debugging surface area.

---

# 91. Phase 0 — Architecture Audit

### Objective

Map the real current VinR codebase before modifying it.

### Tasks

- Identify current `LocalAIService` implementation.
- Identify all callers.
- Identify existing AI-related providers.
- Identify `StorageService`.
- Identify database/storage technology.
- Identify voice recorder implementation.
- Identify STT implementation.
- Identify TTS implementation.
- Identify all Dio/remote AI paths.
- Identify Glint screens/components.
- Identify streak/goal/habit repositories.
- Identify current navigation routes.
- Identify current notification system.
- Identify current build flavors.
- Identify Android/iOS native folders.
- Identify current dependency versions.
- Identify existing tests.

### Deliverable

`VINR_AI_ARCHITECTURE_AUDIT.md`

### Gate

No architectural rewrite begins until all current AI entry points are mapped.

---

# 92. Phase 1 — AI Domain Contracts

### Implement

- `AiTask`
- `AiRequest`
- `AiResponse`
- `AiMessage`
- `AiContext`
- `AiMemory`
- `AiError`
- `AiCapability`

### Add

- unit tests,
- serialization tests,
- error mapping tests.

### Gate

All higher-level code can compile against AI contracts without depending on the native runtime.

---

# 93. Phase 2 — Runtime Spike

### Objective

Choose and validate the actual mobile inference backend/model.

### Tasks

1. Evaluate candidate mobile runtimes.
2. Load candidate model on Android.
3. Load candidate model on iOS.
4. Measure memory.
5. Measure first token.
6. Measure tokens/sec.
7. Measure cold load.
8. Measure warm generation.
9. Test cancellation.
10. Test memory pressure.
11. Test app lifecycle.
12. Test low-end devices.

### Deliverable

A benchmark report.

### Gate

The selected combination must meet the mobile resource envelope.

Do not proceed to full product integration until the runtime is proven on both platforms.

---

# 94. Phase 3 — Model Manager

Implement:

```text
ModelManager
ModelMetadata
ModelInstaller
ModelVerifier
ModelLifecycle
```

### Acceptance

- no duplicate download,
- checksum verification,
- resumable/retry-safe install,
- atomic activation,
- model status observable,
- deletion supported,
- recovery supported.

---

# 95. Phase 4 — AI Scheduler + Orchestrator

Implement:

```text
AiScheduler
AiOrchestrator
AiPolicy
ContextBuilder
ResponseValidator
```

### Acceptance

```text
feature
→ orchestrator
→ scheduler
→ runtime
```

works without UI blocking.

Cancellation and priorities must work.

---

# 96. Phase 5 — Prompt Registry

Create all initial prompt profiles.

Required:

```text
chat
glint
motivation
reflection
planning
goal support
journal
voice
```

Version all prompts.

Add snapshot tests where useful.

---

# 97. Phase 6 — Local Conversation System

Implement:

- conversation repository,
- message repository/storage,
- chat controller,
- streaming UI,
- cancellation,
- retry,
- regenerate,
- persistence,
- local-only privacy policy.

### Gate

Airplane mode test passes.

---

# 98. Phase 7 — Memory / Personalization

Implement:

```text
MemoryRepository
MemoryExtractor
MemoryPolicy
MemoryRetriever
```

### Rules

- local only,
- bounded,
- editable,
- deletable,
- relevance-filtered,
- no automatic storage of every message.

### Gate

A user's conversation remains private and memory can be fully cleared.

---

# 99. Phase 8 — Glint Integration

Implement:

```text
GlintContextBuilder
GlintGenerator
GlintValidator
GlintRepository
GlintCache
```

Create card types.

Add:

```text
motivational card
quote card
streak card
daily focus
reflection
small win
```

### Gate

Glint works:

- online,
- offline,
- with model,
- without model,
- after app restart.

---

# 100. Phase 9 — Glint UX Integration

Use the existing VinR card design language.

The AI must produce **content**.

The existing UI layer decides:

- typography,
- spacing,
- icons,
- gradients,
- animations,
- card dimensions,
- interactions.

Do not let the model control visual layout.

---

# 101. Phase 10 — Voice Repair

Audit and repair the existing pipeline.

### Order

```text
permissions
→ recorder
→ audio file/stream
→ STT
→ AI
→ TTS
```

Add stage-specific diagnostics.

### Gate

Complete voice interaction works repeatedly on Android and iOS.

---

# 102. Phase 11 — Whole-App AI Integration

After chat + Glint + voice are stable, add AI to:

```text
goals
habits
journal
planning
reflection
daily check-ins
notifications
progress explanations
```

Each feature must use the orchestrator.

No direct model calls from feature widgets.

---

# 103. Phase 12 — Performance Hardening

Focus on:

- memory,
- token buffering,
- database writes,
- provider rebuilds,
- model lifecycle,
- cache,
- scheduler,
- background work,
- animations during generation.

Profile real devices.

---

# 104. Phase 13 — Privacy / Security Hardening

Verify:

- conversations never enter remote AI requests,
- no accidental prompt logging,
- no raw voice logging,
- model files validated,
- storage protected,
- delete/reset works,
- no secrets bundled.

---

# 105. Phase 14 — Release Qualification

Run:

```text
offline test suite
Android matrix
iOS matrix
low-memory test
thermal test
battery test
voice test
Glint test
conversation persistence test
model recovery test
app lifecycle test
migration test
```

Only after all gates pass should AI be enabled by default for release.

---

# 106. Suggested Branch Strategy

Use feature branches:

```text
feat/ai-domain
feat/local-runtime
feat/model-manager
feat/ai-orchestrator
feat/ai-chat
feat/ai-memory
feat/glint-ai
feat/voice-repair
feat/app-ai-integration
perf/local-ai
hardening/ai-privacy
```

Merge in dependency order.

Do not merge the entire implementation as one enormous commit.

---

# 107. Suggested Commit Sequence

Example:

```text
feat(ai): add domain contracts
feat(ai): add runtime abstraction
feat(ai): add model manager
feat(ai): add scheduler
feat(ai): add orchestrator
feat(ai): add prompt registry
feat(chat): integrate local inference
feat(ai): add local conversation storage
feat(ai): add memory layer
feat(glint): add structured AI cards
feat(glint): add motivational card generation
fix(voice): repair offline voice pipeline
feat(ai): integrate contextual support
perf(ai): optimize model lifecycle
perf(ai): reduce streaming rebuilds
security(ai): enforce local conversation boundary
test(ai): add device benchmark harness
```

---

# 108. Definition of Done

The project is complete only when all of the following are true.

## AI

- [ ] One local LLM works on Android.
- [ ] One local LLM works on iOS.
- [ ] Model is quantized/mobile appropriate.
- [ ] Model target is approximately 500 MB class.
- [ ] AI subsystem remains within approximately 1.5 GB peak memory.
- [ ] Model does not load synchronously at startup.
- [ ] Inference does not block UI.
- [ ] Generation can be cancelled.
- [ ] Runtime can recover from failure.

## Privacy

- [ ] Conversations remain on-device.
- [ ] No silent remote AI fallback.
- [ ] AI logs contain no private content.
- [ ] User can clear conversations.
- [ ] User can clear memories.
- [ ] User can delete model.

## Chat

- [ ] Streaming works.
- [ ] Persistence works.
- [ ] Conversation history works.
- [ ] Retry works.
- [ ] Regeneration works.
- [ ] Offline operation works.

## Glint

- [ ] AI-generated Glints work.
- [ ] Motivational cards work.
- [ ] Quote cards work.
- [ ] Streak-aware cards work.
- [ ] Structured output is validated.
- [ ] Generated content is cached.
- [ ] Deterministic fallback exists.
- [ ] No fabricated quote attribution.
- [ ] Glint does not regenerate unnecessarily.

## Personalization

- [ ] Relevant local memories are retrieved.
- [ ] Memory writes are controlled.
- [ ] User can clear memories.
- [ ] Responses reflect relevant context.
- [ ] Personalization does not bloat prompts.

## Voice

- [ ] Permission flow works.
- [ ] Recording works.
- [ ] STT works.
- [ ] AI response works.
- [ ] TTS works where enabled.
- [ ] Voice errors are diagnosable.
- [ ] Voice works offline according to the declared privacy policy.

## Performance

- [ ] No sustained UI jank during generation.
- [ ] Background AI is cancellable.
- [ ] Model unloads under memory pressure.
- [ ] No duplicate generation.
- [ ] Token streaming is coalesced.
- [ ] AI database writes are not performed per token.
- [ ] Glint generation is cached/event-driven.
- [ ] Battery/thermal behavior is acceptable.

---

# 109. Recommended Final Architecture

The target architecture should look like:

```text
┌─────────────────────────────────────────────────────────────┐
│                         VINR APP                             │
├─────────────────────────────────────────────────────────────┤
│                         UI / UX                              │
│  Chat │ Glint │ Goals │ Habits │ Journal │ Voice │ etc.     │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                     Riverpod State Layer                    │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                  Feature Use Cases / Repos                   │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                       AI PLATFORM                            │
│                                                             │
│  Orchestrator                                               │
│      │                                                      │
│      ├── Scheduler                                           │
│      ├── Context Builder                                     │
│      ├── Prompt Registry                                     │
│      ├── Memory                                              │
│      ├── Policy / Safety                                     │
│      ├── Validator                                           │
│      ├── Cache                                               │
│      └── Capability Router                                   │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                    LOCAL AI RUNTIME                          │
│                                                             │
│       Model Manager → One Quantized Local LLM               │
│                                                             │
│       Android Native Runtime     iOS Native Runtime          │
└─────────────────────────────────────────────────────────────┘

              LOCAL STORAGE / PRIVACY BOUNDARY
┌─────────────────────────────────────────────────────────────┐
│ Conversations │ Memories │ Glints │ Cache │ Settings        │
└─────────────────────────────────────────────────────────────┘
```

---

# 110. Principal Engineering Decisions

These decisions should be treated as architectural constraints unless a later benchmark proves otherwise.

### Decision 1 — One model

Do not ship multiple LLMs for different features.

Use one capable local model and task-specific prompting.

### Decision 2 — Local-first

AI functionality should not depend on the network.

### Decision 3 — Privacy boundary

Private conversation data never leaves the device.

### Decision 4 — Central orchestration

Features request AI capabilities through the orchestrator rather than calling the model directly.

### Decision 5 — Deterministic application logic

The model handles language; the application handles state and calculations.

### Decision 6 — Glint is structured

The model generates content objects; Flutter renders cards.

### Decision 7 — Lazy inference

Never load the model during app startup.

### Decision 8 — Serialized heavy inference

Default to one heavy generation at a time.

### Decision 9 — Bounded memory

The 1.5 GB figure is a ceiling, not a target to consume.

### Decision 10 — Performance before feature count

A smaller set of fast, reliable AI features is preferable to a feature-complete implementation that causes lag.

### Decision 11 — Voice is a first-class pipeline

Voice must be independently observable and recoverable.

### Decision 12 — Model/runtime replaceability

No feature should know which LLM runtime is underneath.

---

# 111. Final Implementation Order

The practical order is:

```text
                    ┌──────────────────┐
                    │  Architecture    │
                    │      Audit       │
                    └────────┬─────────┘
                             ↓
                    ┌──────────────────┐
                    │ Domain Contracts │
                    └────────┬─────────┘
                             ↓
                    ┌──────────────────┐
                    │ Runtime + Model  │
                    │     Spike        │
                    └────────┬─────────┘
                             ↓
                    ┌──────────────────┐
                    │  Model Manager   │
                    └────────┬─────────┘
                             ↓
                    ┌──────────────────┐
                    │ Scheduler + AI   │
                    │   Orchestrator   │
                    └────────┬─────────┘
                             ↓
              ┌──────────────┼──────────────┐
              ↓              ↓              ↓
           Prompt          Chat           Voice
           System                         Repair
              │              │              │
              └──────────────┼──────────────┘
                             ↓
                    ┌──────────────────┐
                    │ Local Memory /   │
                    │ Personalization  │
                    └────────┬─────────┘
                             ↓
                    ┌──────────────────┐
                    │  Glint + Cards   │
                    └────────┬─────────┘
                             ↓
                    ┌──────────────────┐
                    │ Whole-App AI     │
                    │   Integration    │
                    └────────┬─────────┘
                             ↓
                    ┌──────────────────┐
                    │ Performance +    │
                    │ Privacy Hardening│
                    └────────┬─────────┘
                             ↓
                    ┌──────────────────┐
                    │ Device QA /      │
                    │ Release Gate     │
                    └──────────────────┘
```

---

# 112. Immediate Next Engineering Action

Before implementing features, inspect the actual VinR repository and produce the architecture audit.

Specifically map:

```text
LocalAIService
StorageService
voice/STT/TTS
all AI callers
all Glint code
all repositories
Riverpod providers
Android native bridge
iOS native bridge
Dio/remote AI paths
database schema
existing tests
```

Then implement **Phase 1 → Phase 2** before touching the Glint UI.

The most important rule for the entire project is:

> **Do not let the local LLM become a giant dependency that every part of VinR talks to directly. Build a controlled AI platform around it.**

That gives VinR one local intelligence core while preserving the existing architecture, keeping conversations private, keeping the app responsive, and allowing the same model to power chat, Glints, motivation, planning, reflection, personalization, and voice without downloading a separate model for each feature.
