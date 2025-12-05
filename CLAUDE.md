# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a static website for Samavarta Association (Association Loi 1901), a French non-profit organization that supports and promotes Indian performing arts (music, dance, theater). Created on 07/04/2025.

## Architecture

- **Single-page static website**: `index.html` is the main entry point
- **Styling**: Bootstrap 5.3.0-alpha1 loaded via CDN
- **No build process**: Direct HTML/CSS, no bundler or preprocessor
- **Assets structure**:
  - `/images/` - Gallery photos, icons, logo, and UI elements
  - `/ressources/` - PDF documents (artist portfolio)
  - Root contains the main HTML file and association documents

## Development

To view the website, simply open `index.html` in a browser. No build step or server required.

The website embeds a PDF (`ressources/Familia-Surangama-2025-01.pdf`) directly in the page using the `<embed>` tag.

## Content

The page displays:
- Association objective and activities
- Member information (President, Secretary, Treasurer, Honorary Member)
- Embedded artist portfolio PDF
