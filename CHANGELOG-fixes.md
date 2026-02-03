# FolderView2 Fork Changelog

## Summary

This fork (chodeus/folder.view2) contains fixes for the Advanced Preview tooltip, Docker Compose container grouping, and folder settings page layout.

---

## Changes from upstream (VladoPortos/folder.view2)

### File: `scripts/docker.js`

**Line 407:** Changed container selector from `td.ct-name .appname a` to `td.ct-name .appname`

- Docker Compose containers do not have an `<a>` tag in their title
- This fix allows both Docker Compose and standard containers to be grouped into folders

---

### File: `styles/docker.css`

**Theme-agnostic tooltip styling:**
- Replaced hardcoded colors (`#fff`, `#333`, `#f2f2f2`, `#c5c5c5`, etc.) with `inherit` and `rgba()` values
- Tooltip now inherits colors from Unraid's theme
- Works with all Unraid themes (white, gray, azure, black, custom)

**Specific changes:**
- `.preview-outbox`: `background-color: inherit`, `color: inherit`, `border: 1px solid currentColor`
- `.first-row`: `background-color: rgba(128, 128, 128, 0.1)`, `border: 1px solid rgba(128, 128, 128, 0.3)`
- `.status-header-*`: `background-color: rgba(128, 128, 128, 0.2)`
- `.action a`: `color: inherit`
- `.action a:hover`: `background-color: rgba(128, 128, 128, 0.2)`
- `.info-ct`: `background-color: rgba(128, 128, 128, 0.1)`, `border: 1px solid rgba(128, 128, 128, 0.3)`
- `.info-tabs a`: `color: inherit`
- `.ui-tabs-panel`: `color: inherit`
- `.info-ports a, .info-volumes a`: `color: #6a9fd4` (visible on both light/dark)

**Responsive sizing:**
- `.preview-outbox`: `max-width: 90vw`, `max-height: 80vh` (was fixed 700px x 500px)
- `.tooltipster-content`: `overflow: visible` (was causing content cutoff)

**Removed unnecessary comments from upstream**

---

### File: `styles/folder.css`

**Container order table:**
- Changed `width: 92vw` to `width: 100%` with `table-layout: fixed`
- Added column widths: 75% for Name, 25% for Included
- Table now fits within viewport on all screen sizes

**Tooltip bullet points:**
- Added `list-style: none` to `.canvas form ul` and `.canvas form ul > li`
- Removes misaligned bullet points from settings form

**Order section layout:**
- Added `.order-section` class with flexbox column layout
- `dt` and `dd` display vertically with `float: none`
- "Order:" label appears above the full-width table

---

### File: `Folder.page`

**Removed missing CSS reference:**
- Removed `<link>` to `/plugins/dynamix.docker.manager/styles/style-{theme}.css`
- This file does not exist on Unraid 7.x and caused nginx 404 errors

**Order section restructure:**
- Merged separate "Order:" label div with table div into single `.order-section`
- Removed hardcoded `width: 115em` inline style
- Table is now inside the same `<dd>` as the label for proper form alignment

---

## Version

### 2026.02.03
- Docker Compose containers now group into folders correctly
- Advanced Preview tooltip works with all Unraid themes
- Folder settings page layout fixed for all screen sizes
- Removed nginx 404 errors from missing CSS file
