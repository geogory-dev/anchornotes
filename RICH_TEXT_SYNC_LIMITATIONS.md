# Rich Text Sync Limitations

## Overview

AnchorNotes supports rich text formatting using Flutter Quill. However, there are important limitations to understand regarding how rich text syncs across devices.

## How It Works

### Storage Format
- Rich text is stored as **JSON** (Quill Delta format)
- Plain text notes are automatically converted when opened in the rich editor
- The format is backward compatible - old plain text notes work fine

### Sync Strategy: "Last Write Wins" (LWW)

When syncing rich text notes, AnchorNotes uses a simple "Last Write Wins" strategy:
- The entire document is treated as a single unit
- The most recently modified version overwrites older versions
- Timestamps determine which version is "newer"

## ⚠️ Known Limitations

### Concurrent Editing Conflicts

**The Problem:**
If two people edit the same note while offline, only the last person to sync will have their changes preserved.

**Example Scenario:**
```
Initial note: "Hello World"

User A (offline):
- Makes "Hello" bold
- Syncs at 2:00 PM

User B (offline):  
- Makes "World" italic
- Syncs at 2:05 PM

Result: User B's version wins completely.
        User A's bold formatting is lost! ❌
```

### Why This Happens

Rich text documents are complex structured data (JSON), not simple strings. To properly merge concurrent edits would require:

1. **Operational Transformation (OT)** - Used by Google Docs
2. **CRDTs** (Conflict-free Replicated Data Types) - Used by Figma, Notion

These are PhD-level algorithms that would require weeks/months to implement correctly.

## 💡 Best Practices

To avoid conflicts when using rich text:

### 1. **Stay Online When Collaborating**
- Edit notes while connected to the internet
- Changes sync immediately
- Conflicts are much less likely

### 2. **Check "Last Edited" Timestamp**
- Before editing a shared note, check when it was last modified
- If it was recently edited by someone else, coordinate with them

### 3. **Communicate with Collaborators**
- Let others know when you're editing a shared note
- Avoid editing the same note simultaneously

### 4. **Use Plain Text for Critical Collaboration**
- For notes that need heavy collaboration, consider using plain text
- Plain text conflicts are easier to resolve

### 5. **Save Frequently**
- Manual save button ensures your changes are uploaded
- Auto-save triggers after 2 seconds of inactivity

## 🔮 Future Improvements

Potential solutions for future versions:

### Option 1: Lock-Based Editing
- Show "User X is editing" indicator
- Prevent others from editing until done
- Simple but limits collaboration

### Option 2: Y.js Integration
- Industry-standard CRDT library
- Requires major architecture changes
- Would enable true real-time collaboration

### Option 3: Separate Rich/Plain Modes
- Rich text: Single-user only
- Plain text: Full collaboration
- Clear separation of use cases

## 📊 When to Use Rich Text

**Good Use Cases:**
- ✅ Personal notes
- ✅ Single-author documents
- ✅ Notes with formatting needs (headers, lists, code)
- ✅ Offline-first personal knowledge base

**Avoid Rich Text For:**
- ❌ Real-time collaborative editing
- ❌ Notes edited by multiple people simultaneously
- ❌ Critical documents where no data loss is acceptable

## 🎯 Comparison with Other Apps

| App | Rich Text Sync | Method |
|-----|---------------|--------|
| **Google Docs** | ✅ Perfect | Operational Transformation |
| **Notion** | ✅ Perfect | CRDTs |
| **Apple Notes** | ⚠️ LWW | Last Write Wins (like us) |
| **Simplenote** | ✅ Good | Plain text only |
| **AnchorNotes** | ⚠️ LWW | Last Write Wins |

**Note:** Even Apple Notes uses "Last Write Wins" for rich text! This is a common trade-off for apps that prioritize simplicity and offline-first design.

## 📝 Technical Details

### What Gets Synced

```json
{
  "title": "My Note",
  "content": "[{\"insert\":\"Hello \"},{\"attributes\":{\"bold\":true},\"insert\":\"World\"}]",
  "updatedAt": "2025-10-16T14:30:00Z"
}
```

The entire `content` field is replaced on sync, not merged.

### Conflict Resolution Logic

```dart
if (remoteNote.updatedAt.isAfter(localNote.updatedAt)) {
  // Remote version is newer, use it
  localNote = remoteNote;
} else {
  // Local version is newer, keep it
  // (will be pushed to server)
}
```

## ❓ FAQ

**Q: Will I lose my notes?**
A: No! Notes are never deleted. But concurrent edits may overwrite each other.

**Q: Can I see who edited last?**
A: Yes! The editor shows "Last edited: X minutes ago" at the bottom.

**Q: What if I need perfect collaboration?**
A: Use Google Docs or Notion for documents that need real-time collaboration.

**Q: Is this a bug?**
A: No, it's a known limitation of the simple sync architecture. It's a trade-off for offline-first design.

**Q: Will this be fixed?**
A: Potentially in a future version with Y.js or similar CRDT library.

## 🤝 Contributing

If you're interested in implementing proper CRDT-based sync, we'd love your contribution! See `CONTRIBUTING.md` for details.

---

**Last Updated:** October 16, 2025  
**Version:** 1.0.0
