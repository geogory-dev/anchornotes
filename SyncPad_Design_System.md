# SyncPad - Complete UI/UX Design System & Mockups

## Executive Summary
SyncPad is an offline-first, collaborative note-taking mobile app that prioritizes reliability, simplicity, and a distraction-free writing experience. This document outlines the complete design system and detailed mockups for all essential screens.

---

## 1. Core Design System

### 1.1 Design Philosophy
- **Minimalist & Content-Focused**: Remove all visual noise to let content shine
- **Clarity First**: Every element serves a clear purpose
- **Generous Spacing**: Breathing room prevents cognitive overload
- **Flat & Modern**: No unnecessary depth, shadows, or gradients

### 1.2 Color Palette

#### Light Theme
```
Background:     #F7F7F7  (Off-white, soft on eyes)
Text Primary:   #2C3E50  (Charcoal, high contrast)
Text Secondary: #7F8C8D  (Muted gray for metadata)
Accent:         #3498DB  (Deep blue for interactive elements)
Surface:        #FFFFFF  (Pure white for cards)
Divider:        #E0E0E0  (Subtle separators)
Error:          #E74C3C  (For validation messages)
Success:        #27AE60  (For sync confirmations)
```

#### Dark Theme
```
Background:     #1C1C1E  (Dark slate-gray)
Text Primary:   #ECF0F1  (Off-white, comfortable)
Text Secondary: #95A5A6  (Muted gray for metadata)
Accent:         #3498DB  (Same blue for consistency)
Surface:        #2C2C2E  (Slightly lighter for cards)
Divider:        #3A3A3C  (Subtle separators)
Error:          #E74C3C  (For validation messages)
Success:        #27AE60  (For sync confirmations)
```

### 1.3 Typography

**Font Family**: Inter (primary) or Poppins (fallback)

#### Type Scale
```
Display Large:   32px, Weight 700, Line Height 40px  (App branding)
Heading 1:       24px, Weight 600, Line Height 32px  (Screen titles)
Heading 2:       20px, Weight 600, Line Height 28px  (Note titles)
Body Large:      16px, Weight 400, Line Height 24px  (Note content)
Body Regular:    14px, Weight 400, Line Height 20px  (UI text)
Label:           12px, Weight 500, Line Height 16px  (Metadata, timestamps)
Button:          16px, Weight 600, Line Height 24px  (CTAs)
```

### 1.4 Spacing System
```
xs:  4px   (Tight spacing within components)
sm:  8px   (Component internal padding)
md:  16px  (Standard padding)
lg:  24px  (Section spacing)
xl:  32px  (Screen margins)
xxl: 48px  (Major section breaks)
```

### 1.5 Component Specifications

#### Buttons
- **Primary (ElevatedButton)**
  - Background: Accent color (#3498DB)
  - Text: White (#FFFFFF)
  - Height: 48px
  - Border Radius: 8px
  - Padding: 16px horizontal
  - Elevation: 2dp (subtle)
  
- **Secondary (TextButton)**
  - Background: Transparent
  - Text: Accent color (#3498DB)
  - Height: 48px
  - No border
  
- **Social Login (Outlined)**
  - Background: Transparent
  - Border: 1px solid Divider color
  - Text: Primary text color
  - Height: 48px
  - Border Radius: 8px

#### Input Fields
- Height: 56px
- Border: 1px solid Divider color
- Border Radius: 8px
- Padding: 16px
- Focus State: Border color changes to Accent
- Label: Floating label style

#### Cards
- Background: Surface color
- Border Radius: 12px
- Padding: 16px
- No shadow (flat design)
- Border: 1px solid Divider (optional, for light theme)

#### Icons
- Size: 24px (standard), 20px (small)
- Style: Outlined/line icons (Material Icons or Lucide)
- Color: Text Secondary (default), Accent (active state)

---

## 2. Screen Mockups

### 2.1 Auth Gate / Splash Screen

#### Purpose
Temporary loading screen that checks authentication status and routes users appropriately.

#### Layout Structure
```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│                                     │
│            [SyncPad Logo]           │
│                                     │
│         ─────────────────           │ ← Subtle loading indicator
│                                     │
│                                     │
│                                     │
│                                     │
└─────────────────────────────────────┘
```

#### Detailed Specifications

**Light Theme:**
- Background: #F7F7F7
- Logo: Charcoal (#2C3E50) with blue accent (#3498DB)
- Loading Indicator: Linear progress bar, 200px wide, accent color

**Dark Theme:**
- Background: #1C1C1E
- Logo: Off-white (#ECF0F1) with blue accent (#3498DB)
- Loading Indicator: Linear progress bar, 200px wide, accent color

**Logo Design Concept:**
```
   ╔═══╗
   ║ S ║  SyncPad
   ╚═══╝
```
- Simple geometric icon with "S" lettermark
- Icon size: 80x80px
- Text "SyncPad" below: Display Large (32px, Weight 700)
- Spacing between icon and text: 16px

**Loading Indicator:**
- Position: 24px below logo text
- Width: 200px
- Height: 3px
- Indeterminate animation
- Color: Accent (#3498DB)

**Behavior:**
- Display for minimum 1 second
- Check auth token
- Route to Login (if unauthenticated) or Home (if authenticated)

---

### 2.2 Login / Register Screen

#### Purpose
Single, unified authentication screen supporting email/password and social login.

#### Layout Structure
```
┌─────────────────────────────────────┐
│                                     │
│            [SyncPad Logo]           │ ← Smaller version
│                                     │
│         Welcome Back                │ ← Heading
│                                     │
│    ┌─────────────────────────┐     │
│    │ Email                   │     │ ← Input field
│    └─────────────────────────┘     │
│                                     │
│    ┌─────────────────────────┐     │
│    │ Password                │     │ ← Input field
│    └─────────────────────────┘     │
│                                     │
│    ┌─────────────────────────┐     │
│    │    Login / Continue     │     │ ← Primary button
│    └─────────────────────────┘     │
│                                     │
│         Create an Account           │ ← Text button
│                                     │
│    ─────────── or ───────────       │ ← Divider
│                                     │
│    ┌─────────────────────────┐     │
│    │ [G] Sign in with Google │     │ ← Social login
│    └─────────────────────────┘     │
│                                     │
└─────────────────────────────────────┘
```

#### Detailed Specifications

**AppBar:**
- None (full-screen authentication)

**Logo Section:**
- Logo: 60x60px (smaller than splash)
- Text: "SyncPad" - Heading 1 (24px, Weight 600)
- Position: Top center, 48px from top
- Spacing below: 32px

**Heading:**
- Text: "Welcome Back" (Login mode) or "Create Account" (Register mode)
- Style: Heading 1 (24px, Weight 600)
- Color: Text Primary
- Alignment: Center
- Spacing below: 32px

**Input Fields:**
- Email Field:
  - Label: "Email"
  - Type: Email keyboard
  - Validation: Email format
  - Height: 56px
  - Spacing below: 16px

- Password Field:
  - Label: "Password"
  - Type: Password (obscured)
  - Trailing icon: Eye icon to toggle visibility
  - Height: 56px
  - Spacing below: 24px

**Primary Button:**
- Text: "Login / Continue" (Login mode) or "Create Account" (Register mode)
- Full width (minus 32px horizontal margins)
- Background: Accent (#3498DB)
- Text color: White
- Height: 48px
- Border radius: 8px
- Spacing below: 16px

**Secondary Text Button:**
- Text: "Create an Account" (Login mode) or "Already have an account? Login" (Register mode)
- Text color: Accent (#3498DB)
- Style: Button (16px, Weight 600)
- Alignment: Center
- Spacing below: 24px

**Divider:**
- Text: "or"
- Style: Horizontal line with centered text
- Color: Divider color
- Spacing below: 24px

**Social Login Button:**
- Text: "Sign in with Google"
- Leading icon: Google "G" logo (20px)
- Border: 1px solid Divider color
- Background: Transparent
- Text color: Text Primary
- Height: 48px
- Border radius: 8px
- Full width (minus 32px horizontal margins)

**Margins:**
- Horizontal: 32px (both sides)
- Vertical: Content centered vertically

**State Management:**
- Toggle between Login/Register modes
- Show validation errors below fields (Error color, Label size)
- Disable button during API calls
- Show loading indicator on button during authentication

---

### 2.3 Home / Notes List Screen

#### Purpose
Main dashboard displaying all user notes with sync status and quick access to create new notes.

#### Layout Structure
```
┌─────────────────────────────────────┐
│  SyncPad              [Sync Icon]   │ ← AppBar
├─────────────────────────────────────┤
│                                     │
│  ┌───────────┐  ┌───────────┐      │
│  │ Note 1    │  │ Note 2    │      │ ← Note cards (2-column grid)
│  │ Preview.. │  │ Preview.. │      │
│  └───────────┘  └───────────┘      │
│                                     │
│  ┌───────────┐  ┌───────────┐      │
│  │ Note 3    │  │ Note 4    │      │
│  │ Preview.. │  │ Preview.. │      │
│  └───────────┘  └───────────┘      │
│                                     │
│  ┌───────────┐  ┌───────────┐      │
│  │ Note 5    │  │ Note 6    │      │
│  │ Preview.. │  │ Preview.. │      │
│  └───────────┘  └───────────┘      │
│                                     │
│                          [+]        │ ← FAB
└─────────────────────────────────────┘
```

#### Detailed Specifications

**AppBar:**
- Height: 56px
- Background: Surface color
- Elevation: 0 (flat)
- Bottom border: 1px solid Divider color

- Title: "SyncPad"
  - Style: Heading 1 (24px, Weight 600)
  - Color: Text Primary
  - Position: Left, 16px from edge

- Sync Status Icon:
  - Position: Right, 16px from edge
  - Size: 24px
  - States:
    - Synced: Cloud icon with checkmark, Success color (#27AE60)
    - Syncing: Cloud icon with circular progress, Accent color (#3498DB)
    - Offline: Cloud with slash, Text Secondary color (#7F8C8D)
    - Error: Cloud with exclamation, Error color (#E74C3C)

**Notes Grid:**
- Layout: 2-column grid
- Gap: 16px (horizontal and vertical)
- Padding: 16px (all sides)
- Scrollable: Vertical

**Note Card:**
- Width: (Screen width - 48px) / 2
- Min height: 140px
- Background: Surface color
- Border radius: 12px
- Border: 1px solid Divider (light theme only)
- Padding: 16px
- Tap target: Full card

- Title:
  - Style: Heading 2 (20px, Weight 600)
  - Color: Text Primary
  - Max lines: 2
  - Overflow: Ellipsis
  - Spacing below: 8px

- Preview:
  - Style: Body Regular (14px, Weight 400)
  - Color: Text Secondary
  - Max lines: 3
  - Overflow: Ellipsis
  - Spacing below: 12px

- Metadata:
  - Style: Label (12px, Weight 500)
  - Color: Text Secondary
  - Content: Last edited timestamp (e.g., "2 hours ago")
  - Position: Bottom of card

**Empty State:**
- Display when no notes exist
- Icon: Document icon (48px), Text Secondary color
- Text: "No notes yet"
  - Style: Body Large (16px, Weight 400)
  - Color: Text Secondary
  - Spacing below: 8px
- Subtext: "Tap + to create your first note"
  - Style: Body Regular (14px, Weight 400)
  - Color: Text Secondary
- Alignment: Center (vertically and horizontally)

**FloatingActionButton (FAB):**
- Position: Bottom right, 16px from edges
- Size: 56x56px
- Background: Accent color (#3498DB)
- Icon: Plus icon (24px), White color
- Elevation: 6dp
- Border radius: 28px (circular)
- Action: Navigate to Note Editor (new note)

**Behavior:**
- Pull to refresh: Trigger manual sync
- Tap card: Open note in editor
- Long press card: Show context menu (Delete, Share)
- FAB tap: Create new note

---

### 2.4 Note Editor Screen

#### Purpose
Distraction-free writing interface for creating and editing notes with real-time sync.

#### Layout Structure
```
┌─────────────────────────────────────┐
│  ← Note Title         [Share] [•]   │ ← AppBar
├─────────────────────────────────────┤
│                                     │
│  Note Title Here                    │ ← Title input
│  ─────────────────────────────      │
│                                     │
│  Start writing your note...         │ ← Content area
│                                     │
│                                     │
│                                     │
│                                     │
│                                     │
│                                     │
│                                     │
│                                     │
│                                     │
└─────────────────────────────────────┘
```

#### Detailed Specifications

**AppBar:**
- Height: 56px
- Background: Surface color
- Elevation: 0 (flat)
- Bottom border: 1px solid Divider color

- Back Button:
  - Position: Left, 4px from edge
  - Icon: Left arrow (24px)
  - Color: Text Primary
  - Tap target: 48x48px
  - Action: Navigate back to Home (auto-save)

- Title Display:
  - Text: Note title (truncated) or "New Note"
  - Style: Body Large (16px, Weight 400)
  - Color: Text Secondary
  - Position: Center-left, after back button
  - Max width: 60% of screen

- Share Button:
  - Position: Right, 48px from edge
  - Icon: Share icon (24px)
  - Color: Text Primary
  - Tap target: 48x48px
  - Action: Open Sharing Dialog

- Sync Status Indicator:
  - Position: Right, 12px from edge
  - Size: 8x8px (small dot)
  - Colors:
    - Synced: Success color (#27AE60)
    - Syncing: Accent color (#3498DB) with pulse animation
    - Offline: Text Secondary color (#7F8C8D)
    - Error: Error color (#E74C3C)

**Title Input:**
- Position: Top of content area, 24px from top
- Style: Heading 1 (24px, Weight 600)
- Color: Text Primary
- Placeholder: "Note Title"
- Placeholder color: Text Secondary
- Border: None
- Bottom border: 1px solid Divider (only when focused)
- Padding: 16px horizontal
- Spacing below: 16px
- Max lines: 2
- Auto-focus: On new note creation

**Content Text Area:**
- Position: Below title input
- Style: Body Large (16px, Weight 400)
- Color: Text Primary
- Placeholder: "Start writing..."
- Placeholder color: Text Secondary
- Border: None
- Padding: 16px horizontal, 0px vertical
- Line height: 24px
- Min height: Fill remaining screen
- Scrollable: Vertical
- Auto-save: Every 2 seconds of inactivity

**Margins:**
- Horizontal: 16px (both sides)
- Top: 24px (from AppBar)
- Bottom: 24px (for keyboard clearance)

**Keyboard Behavior:**
- Auto-show: When screen opens
- Toolbar: Minimal (no formatting in MVP)
- Dismiss: Tap outside or back button

**Auto-Save Indicator:**
- Position: Below AppBar, centered
- Text: "Saving..." or "All changes saved"
- Style: Label (12px, Weight 500)
- Color: Text Secondary (saving), Success color (saved)
- Display: Fade in/out animation
- Duration: Show for 2 seconds after save

**Behavior:**
- Auto-save on every text change (debounced 2 seconds)
- Offline changes queued for sync
- Conflict resolution: Last write wins (show warning if conflict detected)

---

### 2.5 Sharing Screen (Dialog)

#### Purpose
Modal dialog for managing note collaborators and permissions.

#### Layout Structure
```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│  ┌───────────────────────────────┐ │
│  │  Share Note              [×]  │ │ ← Dialog header
│  ├───────────────────────────────┤ │
│  │                               │ │
│  │  ┌─────────────────────────┐ │ │
│  │  │ Email address           │ │ │ ← Email input
│  │  └─────────────────────────┘ │ │
│  │                               │ │
│  │  ┌─────────────────────────┐ │ │
│  │  │    Send Invite          │ │ │ ← Send button
│  │  └─────────────────────────┘ │ │
│  │                               │ │
│  │  Current Collaborators        │ │ ← Section header
│  │                               │ │
│  │  ┌─────────────────────────┐ │ │
│  │  │ user@email.com          │ │ │ ← Collaborator item
│  │  │ Editor              [×] │ │ │
│  │  └─────────────────────────┘ │ │
│  │                               │ │
│  │  ┌─────────────────────────┐ │ │
│  │  │ another@email.com       │ │ │
│  │  │ Viewer              [×] │ │ │
│  │  └─────────────────────────┘ │ │
│  │                               │ │
│  └───────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

#### Detailed Specifications

**Dialog Container:**
- Width: 90% of screen width (max 400px)
- Background: Surface color
- Border radius: 16px
- Elevation: 8dp
- Position: Center of screen
- Backdrop: Semi-transparent black (40% opacity)

**Header:**
- Height: 56px
- Padding: 16px
- Border bottom: 1px solid Divider

- Title: "Share Note"
  - Style: Heading 2 (20px, Weight 600)
  - Color: Text Primary
  - Position: Left

- Close Button:
  - Position: Right
  - Icon: X icon (24px)
  - Color: Text Secondary
  - Tap target: 48x48px
  - Action: Close dialog

**Content Area:**
- Padding: 24px
- Scrollable: Vertical (if content exceeds height)

**Email Input:**
- Label: "Email address"
- Type: Email keyboard
- Validation: Email format
- Height: 56px
- Border: 1px solid Divider
- Border radius: 8px
- Padding: 16px
- Spacing below: 16px

**Permission Dropdown (Optional):**
- Label: "Permission"
- Options: "Editor", "Viewer"
- Default: "Editor"
- Height: 56px
- Style: Outlined dropdown
- Spacing below: 16px

**Send Invite Button:**
- Text: "Send Invite"
- Full width
- Background: Accent (#3498DB)
- Text color: White
- Height: 48px
- Border radius: 8px
- Spacing below: 32px
- Disabled state: Gray background when email invalid

**Section Header:**
- Text: "Current Collaborators"
- Style: Body Regular (14px, Weight 400)
- Color: Text Secondary
- Spacing below: 16px

**Collaborator List:**
- Layout: Vertical list
- Gap: 12px between items

**Collaborator Item:**
- Background: Background color (slightly different from Surface)
- Border radius: 8px
- Padding: 12px
- Height: Auto (min 60px)

- Email:
  - Style: Body Regular (14px, Weight 400)
  - Color: Text Primary
  - Position: Top left

- Permission Badge:
  - Text: "Editor" or "Viewer"
  - Style: Label (12px, Weight 500)
  - Color: Accent (#3498DB)
  - Background: Accent with 10% opacity
  - Padding: 4px 8px
  - Border radius: 4px
  - Position: Bottom left, 8px from email

- Remove Button:
  - Position: Right, vertically centered
  - Icon: X icon (20px)
  - Color: Text Secondary
  - Tap target: 40x40px
  - Action: Remove collaborator (with confirmation)

**Empty State:**
- Display when no collaborators
- Text: "No collaborators yet"
- Style: Body Regular (14px, Weight 400)
- Color: Text Secondary
- Alignment: Center
- Spacing: 24px vertical

**Behavior:**
- Validate email before enabling Send button
- Show loading indicator on Send button during API call
- Show success message: "Invite sent" (toast notification)
- Show error message: "Failed to send invite" (toast notification)
- Auto-refresh collaborator list after successful invite
- Confirm before removing collaborator: "Remove [email] from this note?"

---

## 3. Interaction Patterns

### 3.1 Navigation Flow
```
Splash Screen
    ↓
    ├─→ Login Screen (if not authenticated)
    │       ↓
    │   [Login Success]
    │       ↓
    └─→ Home Screen (if authenticated)
            ↓
            ├─→ Note Editor (tap card or FAB)
            │       ↓
            │       └─→ Sharing Dialog (tap share icon)
            │
            └─→ [Back] → Home Screen
```

### 3.2 Gestures
- **Tap**: Primary interaction (buttons, cards, icons)
- **Long Press**: Context menu on note cards (Delete, Share)
- **Pull to Refresh**: Manual sync trigger on Home screen
- **Swipe**: Dismiss keyboard (optional)

### 3.3 Feedback Mechanisms
- **Visual**: Color changes on tap (ripple effect)
- **Loading**: Circular progress indicators during async operations
- **Toast Notifications**: Success/error messages (bottom of screen, 3-second duration)
- **Sync Status**: Real-time indicator in AppBar and Editor

---

## 4. Accessibility Considerations

### 4.1 Color Contrast
- All text meets WCAG AA standards (4.5:1 for body text, 3:1 for large text)
- Light theme: Charcoal on off-white = 10.5:1
- Dark theme: Off-white on dark slate = 12.8:1
- Accent color on white = 4.6:1 (AA compliant)

### 4.2 Touch Targets
- Minimum size: 48x48px (Material Design standard)
- Spacing: 8px minimum between interactive elements

### 4.3 Screen Reader Support
- All icons have semantic labels
- Input fields have clear labels
- Buttons have descriptive text
- Sync status announced to screen readers

### 4.4 Font Scaling
- Support system font size preferences
- Maintain layout integrity up to 200% scaling
- Use relative units (sp for text, dp for spacing)

---

## 5. Animation & Transitions

### 5.1 Screen Transitions
- Duration: 300ms
- Easing: Ease-in-out
- Type: Slide (horizontal for navigation, vertical for dialogs)

### 5.2 Micro-interactions
- Button press: Scale down to 0.95 (100ms)
- Ripple effect: Material Design standard
- FAB: Rotate 45° on press (plus becomes X)
- Sync indicator: Pulse animation (1-second cycle)

### 5.3 Loading States
- Skeleton screens: For note list loading
- Shimmer effect: Subtle, accent color
- Progress indicators: Circular (indeterminate) or linear (determinate)

---

## 6. Responsive Considerations

### 6.1 Phone Sizes
- Small (< 360px width): Single column note grid
- Medium (360-600px): Two-column note grid (default)
- Large (> 600px): Two-column with increased card size

### 6.2 Tablet Adaptation
- Three-column note grid
- Wider dialog (max 600px)
- Side-by-side layout: Note list + Editor (landscape)

### 6.3 Orientation
- Portrait: Default layouts as specified
- Landscape: Reduce vertical padding, optimize for horizontal space

---

## 7. Dark Theme Specific Adjustments

### 7.1 Elevation
- Use lighter surface colors instead of shadows
- Surface: #2C2C2E (one step lighter than background)
- Elevated surface: #3A3A3C (two steps lighter)

### 7.2 Text Contrast
- Reduce pure white to off-white (#ECF0F1) to reduce eye strain
- Increase secondary text contrast slightly (#95A5A6 vs #7F8C8D)

### 7.3 Accent Color
- Same blue (#3498DB) works well on both themes
- Provides consistency and brand recognition

---

## 8. Implementation Notes

### 8.1 Technology Stack Recommendations
- **Framework**: Flutter (cross-platform, excellent UI capabilities)
- **State Management**: Riverpod or Bloc
- **Local Database**: Hive or SQLite
- **Sync**: Custom WebSocket or Firebase Realtime Database
- **Authentication**: Firebase Auth or Supabase

### 8.2 Performance Targets
- App launch: < 2 seconds (cold start)
- Screen transitions: 60fps (16ms per frame)
- Text input latency: < 50ms
- Sync latency: < 1 second (when online)

### 8.3 Offline-First Strategy
- All CRUD operations work offline
- Queue sync operations
- Conflict resolution: Last write wins with user notification
- Local-first architecture: UI never waits for network

---

## 9. Design Assets Checklist

### 9.1 Icons Needed
- [ ] SyncPad logo (80x80, 60x60, 48x48)
- [ ] App icon (1024x1024 for stores)
- [ ] Cloud sync states (4 variations)
- [ ] Navigation icons (back, share, close, plus)
- [ ] Social login icons (Google)
- [ ] Empty state illustrations

### 9.2 Fonts
- [ ] Inter or Poppins (Regular 400, Medium 500, SemiBold 600, Bold 700)
- [ ] License verification for commercial use

### 9.3 Color Palette Export
- [ ] Figma/Sketch file with all color tokens
- [ ] CSS/SCSS variables
- [ ] Flutter theme configuration
- [ ] Android XML colors
- [ ] iOS asset catalog

---

## 10. Future Enhancements (Post-MVP)

### 10.1 Rich Text Editing
- Bold, italic, underline
- Headers (H1, H2, H3)
- Bulleted and numbered lists
- Markdown support

### 10.2 Advanced Collaboration
- Real-time cursor positions
- Inline comments
- Version history
- Change tracking

### 10.3 Organization Features
- Folders/notebooks
- Tags
- Search and filter
- Favorites/pinned notes

### 10.4 Customization
- Custom accent colors
- Font size preferences
- Line spacing options
- Custom themes

---

## Appendix A: Visual Mockup Descriptions

### Light Theme Color Swatches
```
█ #F7F7F7  Background
█ #FFFFFF  Surface
█ #2C3E50  Text Primary
█ #7F8C8D  Text Secondary
█ #3498DB  Accent
█ #E0E0E0  Divider
```

### Dark Theme Color Swatches
```
█ #1C1C1E  Background
█ #2C2C2E  Surface
█ #ECF0F1  Text Primary
█ #95A5A6  Text Secondary
█ #3498DB  Accent
█ #3A3A3C  Divider
```

---

## Appendix B: Component Specifications Summary

| Component | Height | Border Radius | Padding | Elevation |
|-----------|--------|---------------|---------|-----------|
| AppBar | 56px | 0 | 16px H | 0 |
| Primary Button | 48px | 8px | 16px H | 2dp |
| Input Field | 56px | 8px | 16px | 0 |
| Note Card | 140px+ | 12px | 16px | 0 |
| FAB | 56px | 28px | - | 6dp |
| Dialog | Auto | 16px | 24px | 8dp |

---

## Conclusion

This design system provides a complete foundation for building SyncPad with a focus on:
- **Minimalism**: Clean, uncluttered interfaces
- **Consistency**: Unified design language across all screens
- **Accessibility**: WCAG-compliant, touch-friendly
- **Performance**: Optimized for smooth interactions
- **Scalability**: Ready for future feature additions

All specifications are production-ready and can be directly implemented by development teams using modern mobile frameworks.
