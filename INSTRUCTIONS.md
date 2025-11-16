# Technical Challenge

## Screen Recording Requirement

While working on this challenge, please record your entire screen for the full duration of your implementation. This includes your IDE, AI tools, any resources you consult, and other relevant activity.

We’re not assessing your ability to complete the task without looking things up. Instead, we’re interested in how you research, problem-solve, and implement your solutions.

## Submission Deadline

Please return your completed challenge, including all deliverables and the screen recording, within **48 hours** of receiving this brief.

---

## 1 • Scenario

A wellness app shows a running feed of short text‑only check‑ins (e.g. “Today I’ll jog at 6 pm”, “Feeling great after meditation”). You receive a blank `HomeScreen` and a fully configured Firebase project (Auth + Firestore). Your task is to wire up a realtime, offline‑resilient feed that demonstrates clean architecture, solid state‑management, and thoughtful performance handling.

## 2 • What you must build

### Anonymous sign‑in

- On app start, silently call `FirebaseAuth.instance.signInAnonymously()` if no user is present.

### Composer

- Single‑line text field (max 140 chars) and a “Post” button.
- Button is disabled until text is non‑empty; clears on successful send.

### Optimistic post & offline support

- Tapping “Post” should immediately add the item to the local UI, even if offline.
- Save to Cloud Firestore under `/posts/{docId}`:
  - `uid`: String
  - `text`: String
  - `createdAt`: Timestamp
- Ensure duplicate posts aren’t created if a failed write is retried.
- You may rely on Firestore’s built‑in cache or a custom local store—explain the trade‑off in the README.

### Realtime feed

- Stream `/posts` ordered by `createdAt desc`.
- Cards display the text and relative time (e.g. “3 m ago”).
- Feed updates live if another device adds a post.

### Performance & load‑time considerations

- Use lazy loading / pagination or other strategies you deem necessary; reasoning is more important than measured timings.
- Avoid rebuilding the whole list on every snapshot if possible.

### State‑management: Bloc (required)

- Use `bloc`/`flutter_bloc` for all app state.
- Do not use Provider, Riverpod, or GetX.

## 3 • Automated test requirement

- Provide one automated test (unit or widget) that injects a fake post and verifies it appears in state/UI without duplication.

## 4 • Deliverables

- Updated `lib/` that runs via plain `flutter run`.
- Must use `bloc`/`flutter_bloc` for state management.
- A concise README (≤ 300 words) that explains:
  - Your state‑management and architectural choices.
  - Your Bloc approach and how it satisfies the requirements.
  - How offline support and optimistic posting are achieved.
  - Steps you took (or would take) to keep first render and list rebuilding fast.
- Screen recording of your full session.

## 5 • Evaluation approach (qualitative)

Reviewers will look for:

- Clarity and appropriateness of state‑management.
- Correct usage of Bloc (events/states or cubits) with clear separation of concerns.
- Stream handling that avoids unnecessary rebuilds and addresses pagination or caching when relevant.
- Efficient rebuild minimization appropriate to the Bloc structure.
- Correct, unobtrusive anonymous auth integration.
- Thoughtful offline strategy with optimistic UI that resolves conflicts cleanly.
- Evidence of clean architecture: separation of concerns, readable code, testability.
- Quality of the single automated test.
- Depth of reasoning in the README around performance and design trade‑offs.

> **Focus on delivering a lean, coherent slice that highlights your real‑world Flutter and Firebase fluency under time pressure.**
