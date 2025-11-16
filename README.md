# Wellness Feed App

A real-time wellness check-in feed built with Flutter, Firebase, and Bloc state management.

## Architecture & State Management

This app follows **clean architecture** principles with clear separation of concerns:

- **Presentation Layer**: Widgets (`HomeScreen`, `PostComposer`, `PostList`, `PostCard`) focused solely on UI rendering
- **Business Logic Layer**: `PostBloc` manages all application state and business rules using the BLoC pattern
- **Data Layer**: `PostRepository` abstracts Firestore operations, enabling testability and future flexibility

### Bloc Approach

The `PostBloc` handles all state through events (`AddPost`, `LoadPosts`, `PostsReceived`, `LoadMorePosts`) and emits immutable states. This ensures:
- Single source of truth for post data
- Predictable state changes via discrete events
- Easy testing through `bloc_test` library
- Clear separation between UI and business logic

## Offline Support & Optimistic Posting

**Optimistic UI** is achieved by:
1. Immediately adding posts to local state with `hasSentToServer: false` flag
2. Assigning client-generated UUIDs to prevent duplicates during retries
3. Using Firestore's `set()` with `merge: true` to ensure idempotent writes
4. Merging optimistic posts with server posts in `PostBloc._onPostsReceived()`

**Offline resilience** relies on Firestore's built-in caching and persistence. Posts created offline queue automatically and sync when connectivity returns. The optimistic posts display immediately, then transition to server-confirmed posts once synced.

## Performance Optimizations

**First render:**
- Anonymous auth occurs in `main()` before app loads
- `ListView.builder` renders only visible items (lazy rendering)
- Pagination limits initial load to 20 posts via `PostRepository.postsPerPage`

**Rebuild minimization:**
- `BlocBuilder` rebuilds only when `PostState` changes
- `ValueKey(post.id)` on `PostCard` widgets helps Flutter efficiently update lists
- Scroll-based pagination triggers at 90% scroll depth to preload next page
- Individual post widgets are stateless, minimizing widget tree depth

**Stream handling:**
- Single Firestore stream subscription per session
- Stream cancellation in `PostBloc.close()` prevents memory leaks
- Merging logic avoids duplicate posts from concurrent optimistic/server updates

## Testing

Run tests with:
```bash
flutter test
```

The `test/post_bloc_test.dart` suite verifies:
- Post duplication prevention via UUID-based idempotency
- Optimistic posting appears immediately in state
- Firestore stream integration loads server posts correctly
- Merging logic prevents duplicate posts after server sync
