# SMA App – UI Implementation Guide (Safe Version)

## 1. Scope

This document contains ONLY:

* UI layout
* Styling
* Component structure

This document EXCLUDES:

* State management
* API logic
* Provider changes
* Navigation changes

Use existing:

* Providers
* ApiService
* Routes

---

## 2. Global UI System

### Colors

Use existing constants (do NOT redefine):

* Primary: `#FF6B35`
* Secondary: `#004E64`
* Background: `#F8F9FA`
* Surface: `#FFFFFF`
* Text Primary: `#212529`
* Text Secondary: `#6C757D`
* Error: `#DC3545`
* Success: `#28A745`

---

### Typography

* Font: **Poppins**
* Use Theme text styles (do NOT hardcode everywhere)

| Style    | Size  |
| -------- | ----- |
| Headline | 24–32 |
| Title    | 18–20 |
| Body     | 14–16 |
| Caption  | 12    |

---

### Buttons

#### Primary Button (Elevated)

* Background: Primary
* Text: White
* Radius: 8px
* Padding: vertical 12–16

#### Secondary Button (Outlined)

* Border: Primary
* Text: Primary

#### Loading State

* Replace text with `CircularProgressIndicator`

---

## 3. Reusable UI Components

### Card

* Background: White
* Radius: 12px
* Elevation: 2
* Padding: 12–16

---

### Empty State

* Icon (centered)
* Title
* Subtitle
* Optional action button

---

### Loading State

* Centered CircularProgressIndicator

---

### Error State

* Error icon
* Message
* Retry button

---

### Badge

* Small rounded container
* Used for:

  * Cart count
  * Status labels

---

## 4. Screen-Level UI Guidelines

---

## 4.1 Home Screen (UI Only)

* AppBar:

  * Location text (left)
  * Search + notification icons (right)

* Body:

  * Optional banner (SMA active)
  * List of restaurant cards

### Restaurant Card

* Image (top)
* Name + rating
* Cuisine
* Location
* Delivery time + price

⚠️ Do NOT change:

* Data source
* Navigation logic

---

## 4.2 Restaurant Detail Screen (UI Only)

* Collapsible image header
* Restaurant info section
* Tab bar (Menu / Info)

### Menu Item Card

* Image
* Name
* Description
* Price
* "ADD" button

⚠️ ADD button must use existing cart logic

---

## 4.3 Cart Screen (UI Only)

### Layout

* Restaurant banner (top)
* List of items
* Bill summary
* Checkout button

### Cart Item

* Image
* Name
* Price
* Quantity controls

⚠️ IMPORTANT:

* Do NOT manage quantity locally
* Always use existing CartProvider methods

---

### Empty Cart

* Icon
* "Your cart is empty"
* Button → go to home

---

## 4.4 SMA Screen (UI Only)

* Toggle switch (SMA active)
* Recommendation card
* "Get Suggestions" button

⚠️ Do NOT:

* Trigger background logic
* Modify scheduler

---

## 4.5 Profile Screen (UI Only)

* Avatar

* Name + email

* List tiles:

  * Account
  * Preferences
  * Support

* Logout button

⚠️ Logout must use existing auth logic

---

## 5. Navigation Rules (DO NOT CHANGE)

* Use existing routes
* Do NOT introduce new navigation patterns
* Do NOT change route names

---

## 6. Strict Constraints

Copilot / Developer MUST:

✔ Use existing Providers
✔ Use existing ApiService
✔ Reuse current models

❌ Do NOT:

* Create new providers
* Hardcode API data
* Duplicate state
* Introduce new architecture

---

## 7. Implementation Strategy

Implement ONE screen at a time:

1. Build UI layout
2. Connect to existing provider
3. Verify behavior
4. Move to next screen

---

## 8. Key Principle

This is a **UI enhancement only**.

All business logic:

* Already exists
* Must remain unchanged

---
