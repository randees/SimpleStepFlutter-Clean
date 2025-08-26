# Documentation Guidelines & Organization Policy

This document provides clear guidelines for organizing and maintaining documentation in the SimpleStep Flutter project.

## 📁 Directory Structure Policy

### Primary Documentation Location
- **ALL** documentation files (`.md`) must be placed in the `/docs` directory
- **EXCEPTION**: Only the main `README.md` remains in the project root

### Prohibited Locations
- ❌ **Root directory** - No `.md` files except main `README.md`
- ❌ **Source directories** (`/lib`, `/android`, `/ios`) - Keep focused on code
- ❌ **Build directories** (`/build`, `.dart_tool`) - Temporary files only

## 📝 File Naming Conventions

### Standard Patterns
- **Guides**: `{topic}_guide.md` (e.g., `supabase_setup_guide.md`)
- **Testing**: `{component}_TESTING_GUIDE.md` (e.g., `MCP_TESTING_GUIDE.md`)
- **Summaries**: `{phase}_SUMMARY.md` (e.g., `PHASE_1_COMPLETION_SUMMARY.md`)
- **Configuration**: `{tool}_instructions.md` (e.g., `copilot_instructions.md`)

### File Name Requirements
- Use **snake_case** for multi-word topics
- Use **UPPER_CASE** for emphasis (TESTING, SUMMARY, etc.)
- Be descriptive but concise
- Avoid special characters except underscores and hyphens

## 🗂️ Content Categories

When creating new documentation, categorize it appropriately:

### 1. 🚀 Getting Started
- Project overviews
- Quick start guides
- Architecture documentation
- **Files**: `project_overview.md`, `technical_documentation.md`

### 2. 🔧 Setup & Configuration
- Installation guides
- Backend setup
- Environment configuration
- **Files**: `*_setup_guide.md`, `*_integration.md`

### 3. 🏥 Health Connect Integration
- Health platform guides
- Integration documentation
- Platform-specific setup
- **Files**: `HEALTH_CONNECT_TESTING_GUIDE.md`, `react_native_health_integration_guide.md`

### 4. 🧪 Testing & Debugging
- Testing procedures
- Debugging guides
- Troubleshooting
- **Files**: `*_TESTING_GUIDE.md`, `QUICK_TEST.md`, `troubleshooting_guide.md`

### 5. 📊 Development & Maintenance
- Project summaries
- Migration documentation
- Cleanup procedures
- **Files**: `*_SUMMARY.md`, `*_CLEANUP_SUMMARY.md`

### 6. 🏗️ Project Phases
- Phase completion reports
- Milestone documentation
- **Files**: `PHASE_*_COMPLETION_SUMMARY.md`

### 7. 🔒 Security & Configuration
- Security policies
- Tool configuration
- **Files**: `SECURITY.md`, `*_instructions.md`

## 📋 Documentation Index Maintenance

### README.md Requirements
The `docs/README.md` must always:
- ✅ **List ALL** documentation files with descriptions
- ✅ **Categorize** files using the standard categories above
- ✅ **Provide links** to each document
- ✅ **Include project structure** overview
- ✅ **Update date** when modified

### Adding New Documentation
When creating new documentation:

1. **Place file** in `/docs` directory
2. **Follow naming** conventions above
3. **Update index** in `docs/README.md`
4. **Add to appropriate** category section
5. **Include clear description** of file purpose

### Index Update Template
```markdown
- **[Document Title](filename.md)** - Brief description of content and purpose
```

## 🔄 Maintenance Procedures

### Regular Cleanup Tasks
- **Quarterly review** of documentation relevance
- **Remove outdated** guides and summaries
- **Consolidate duplicate** information
- **Update broken** links and references

### Quality Standards
- ✅ Clear, descriptive titles
- ✅ Proper markdown formatting
- ✅ Consistent style and tone
- ✅ Updated information
- ✅ Working links and references

### File Organization Rules
- **No duplicate** files between `/Docs` and other directories
- **Remove files** from root when moved to `/Docs`
- **Verify links** still work after moves
- **Update cross-references** between documents

## 🤖 AI Agent Instructions

### For GitHub Copilot and Future Agents

When working with documentation:

1. **ALWAYS check** if documentation already exists before creating new files
2. **PLACE ALL** new `.md` files in `/docs` directory
3. **UPDATE** `docs/README.md` index when adding/removing documentation
4. **FOLLOW** naming conventions specified above
5. **CATEGORIZE** appropriately using the 7 standard categories
6. **CONSOLIDATE** rather than create duplicate documentation
7. **VERIFY** no `.md` files remain in project root except main `README.md`

### Automatic Organization Commands
When asked to "organize documentation" or similar:
```bash
# Move all .md files (except README.md) to docs/
find . -maxdepth 1 -name "*.md" ! -name "README.md" -exec mv {} docs/ \;

# Update the documentation index
# Edit docs/README.md to include all files with proper categorization
```

### Verification Commands
```bash
# Check for stray documentation files
find . -name "*.md" ! -path "./docs/*" ! -name "README.md"

# List all documentation files
ls -la docs/*.md
```

## 📚 Examples

### Good Documentation Organization
```
/docs/
├── README.md                           # Main documentation index
├── project_overview.md                 # Getting Started
├── supabase_setup_guide.md            # Setup & Configuration  
├── MCP_TESTING_GUIDE.md               # Testing & Debugging
└── PHASE_1_COMPLETION_SUMMARY.md      # Project Phases
```

### Bad Documentation Organization
```
/                                       # ❌ Documentation scattered
├── setup.md                          # ❌ In root directory
├── lib/
│   └── config_guide.md               # ❌ In source directory
└── docs/
    ├── setup.md                      # ❌ Duplicate file
    └── README.md
```

## 📞 Contact & Updates

This guideline document should be updated whenever:
- New documentation categories are needed
- Naming conventions change
- Project structure evolves
- AI agent instructions need modification

---

*Established: August 22, 2025*  
*Last Updated: August 22, 2025*
